//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 29.12.2022.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    
    private lazy var profileImage = UIImageView()
    private lazy var logoutButton = UIButton()
    private lazy var userNameLabel = UILabel()
    private lazy var userEmailLabel = UILabel()
    private lazy var userDescriptionLabel = UILabel()
    
    private var profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        updateProfileDetails(profile: profileService.profile)
        
        setNotificationObserver()
        updateAvatar()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Observer
    
    private func setNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
    
    // MARK: Behaviour
    @objc private func logout() {
        UIBlockingProgressHUD.show()
        clearUserDataFromMemory()
        UIBlockingProgressHUD.dismiss()
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = AuthViewController()
        
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        userNameLabel.text = profile.name
        userEmailLabel.text = profile.loginName
        userDescriptionLabel.text = profile.bio
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImage.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"), options: [.processor(processor)])
    }
    
    private func clearUserDataFromMemory() {
        // хранилище - удалить токен
        OAuth2TokenStorage().token = nil
        // вебвью - удалить куки
        WebViewViewController.clean()
    }
    
    // MARK: UI setup
    
    private func setupUI() {
        
        view.backgroundColor = .ypBlack
        
        setupProfileImage()
        setupLogoutButton()
        setupUserNameLabel()
        setupUserEmail()
        setupUserDescription()
        
    }
    
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.image = UIImage(named: "person.crop.circle.fill")
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
        ])
    }
    
    private func setupUserNameLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userNameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .ypWhite
        userNameLabel.text = "Екатерина Новикова"
        
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -124),
        ])
    }
    
    private func setupUserEmail() {
        view.addSubview(userEmailLabel)
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userEmailLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userEmailLabel.textColor = .ypGrey
        userEmailLabel.text = "@ekaterina.nov"
        
        NSLayoutConstraint.activate([
            userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userEmailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupUserDescription() {
        view.addSubview(userDescriptionLabel)
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userDescriptionLabel.textColor = .ypWhite
        userDescriptionLabel.text = "Hello, world!"
        
        NSLayoutConstraint.activate([
            userDescriptionLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: 8),
            userDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -282),
        ])
    }
}
