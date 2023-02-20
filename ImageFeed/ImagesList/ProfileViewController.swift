//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 29.12.2022.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    private lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(named: "person.crop.circle.fill")
        imageView.backgroundColor = .clear
        
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
        label.textColor = .ypWhite
        label.text = "Екатерина Новикова"
        
        return label
    }()
    private lazy var userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypGrey
        label.text = "@ekaterina.nov"
        
        return label
    }()
    private lazy var userDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .ypWhite
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
    
    private var animationLayers: [CALayer] = []
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        updateProfileDetails(profile: profileService.profile)
                
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
            self.removeGradientsFromSuperLayer()
            print("ProfileViewController setNotificationObserver finished work")
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
        profileImage.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    // MARK: Проверить, почему не удаляется из вью
    
    private func setupAnimatedGradientLayers() {
        profileImage.layer.addSublayer(createCAGradientLayer(width: 70, height: 70))
        userNameLabel.layer.addSublayer(createCAGradientLayer(width: 223, height: 24))
        userEmailLabel.layer.addSublayer(createCAGradientLayer(width: 89, height: 24))
        userDescriptionLabel.layer.addSublayer(createCAGradientLayer(width: 67, height: 24))
        
    }
    
    private func createCAGradientLayer(width: Double, height: Double) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = height / 2
        gradient.masksToBounds = true
        
        setupAnimationOfCAGradientLayer(for: gradient)
        animationLayers.append(gradient)
        
        return gradient
    }
    
    private func setupAnimationOfCAGradientLayer(for layer: CAGradientLayer) {
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 1.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        layer.add(gradientChangeAnimation, forKey: "locations")
    }
    
    private func removeGradientsFromSuperLayer() {
        for index in 0..<animationLayers.count {
            animationLayers[index].removeFromSuperlayer()
        }
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
