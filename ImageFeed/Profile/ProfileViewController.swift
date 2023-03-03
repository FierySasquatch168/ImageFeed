//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 29.12.2022.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private var alertModel: AlertModel?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var avatarCornerRadius: CGFloat = 35
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "person.crop.circle.fill")
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 70),
            imageView.widthAnchor.constraint(equalToConstant: 70)
        ])
        
        return imageView
    }()
    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        return button
    }()
    private lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 23, weight: .bold)
        label.layer.masksToBounds = true
        label.clipsToBounds = true
        label.textColor = .ypWhite
        label.text = "Имя пользователя"
        
        return label
    }()
    private lazy var userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGrey
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.text = "@логин_пользователя"
        
        return label
    }()
    private lazy var userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
        label.clipsToBounds = true
        label.layer.masksToBounds = true
        label.text = "Hello, world!"
        
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .leading
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(profileImage)
        stackView.addArrangedSubview(userNameLabel)
        stackView.addArrangedSubview(userEmailLabel)
        stackView.addArrangedSubview(userDescriptionLabel)
        
        return stackView
    }()
    
    private var profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGradients()
        setNotificationObserver()
        updateProfileDetails(profile: profileService.profile)
        updateAvatar()
        
    }
    
    // MARK: Observer
    
    func setNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
    
    // MARK: Behavior
    @objc private func logout() {
        showLogoutAlert()
    }
    
    private func clearUserDataFromMemory() {
        // хранилище - удалить токен
        OAuth2TokenStorage().token = nil
        // вебвью - удалить куки
        WebViewViewController.clean()
    }
    
    private func updateProfileDetails(profile: Profile?) {
        guard let profile = profile else { return }
        userNameLabel.text = profile.name
        userEmailLabel.text = profile.loginName
        userDescriptionLabel.text = profile.bio
        removeGradients()
    }
    
    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: avatarCornerRadius)
        profileImage.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    func setupGradients() {
        profileImage.addGradient(frame: CGRect(x: 0, y: 0, width: 70, height: 70), cornerRadius: 35)
        userNameLabel.addGradient(frame: CGRect(x: 0, y: 0, width: 223, height: 30), cornerRadius: 15)
        userEmailLabel.addGradient(frame: CGRect(x: 0, y: 0, width: 150, height: 20), cornerRadius: 10)
        userDescriptionLabel.addGradient(frame: CGRect(x: 0, y: 0, width: 90, height: 20), cornerRadius: 10)
    }
    
    private func removeGradients() {
        profileImage.removeGradient()
        userNameLabel.removeGradient()
        userEmailLabel.removeGradient()
        userDescriptionLabel.removeGradient()
    }
    
    // MARK: UI setup
    
    private func setupUI() {
        
        view.backgroundColor = .ypBlack
        
        setupStackView()
        setupLogoutButton()
        
    }
    
    private func setupStackView() {
        view.addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
        ])
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26)
        ])
    }
}

extension ProfileViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        self.present(alert, animated: true)
    }
    
    func showLogoutAlert() {
        let alert = AlertModel(title: "Пока-пока!",
                               message: "Уверены, что хотите выйти?",
                               buttonText: "Да",
                               actionText: "Нет", leftCompletion: { [weak self] _ in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.clearUserDataFromMemory()
            UIBlockingProgressHUD.dismiss()
            guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
            window.rootViewController = SplashViewController()
        })
        
        
        alertPresenter = AlertPresenter(alertDelegate: self)
        alertPresenter?.presentAlertController(alert: alert)
    }
    
}
