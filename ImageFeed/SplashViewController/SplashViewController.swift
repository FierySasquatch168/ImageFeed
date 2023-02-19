//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import UIKit
import ProgressHUD

class SplashViewController: UIViewController {

    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    
    private var alertModel: AlertModel?
    private var alertPresenter: AlertPresenterProtocol?
    
    private lazy var splashViewLogo: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "Vector")
        
        return imageView
    }()
    
    // MARK: Lifecycle
    // TODO: override color appearence for dark mode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupSplashViewLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let token = oAuth2TokenStorage.token {
            fetchProfile(token: token)
        } else {
            switchToAuthViewController()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: Behaviour
    
    private func switchToTabBarController() {
        let tabbarVC = TabBarController()
        tabbarVC.modalPresentationStyle = .fullScreen
        
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = tabbarVC
    }
    
    private func switchToAuthViewController() {
        let authVC = AuthViewController()
        authVC.authViewControllerDelegate = self
        
        let navVC = CustomNavigationController(rootViewController: authVC)
        navVC.modalPresentationStyle = .fullScreen
        
        self.present(navVC, animated: true)
    }
    
    // MARK: Style
    
    private func setupSplashViewLogo() {
        
        view.addSubview(splashViewLogo)
        splashViewLogo.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            splashViewLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashViewLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: Extension AuthVC delegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            UIBlockingProgressHUD.show()
            self.fetchOAuthToken(code: code)
        }
    }
    
    private func fetchOAuthToken(code: String) {
        oAuth2Service.fetchAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure:
                // TODO: Show alert
                UIBlockingProgressHUD.dismiss()
                self.showAuthErrorAlert()
            }
        })
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token: token) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profile):
                guard let username = profile.username else { return }
                ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
                    
                    UIBlockingProgressHUD.dismiss()
                    self.switchToTabBarController()
                    
                    switch result {
                    case .failure(let error):
                        print(error)
                    case .success(let imageName):
                        print(imageName)
                    }
                }
            case .failure(let error):
                // TODO: Show alert
                UIBlockingProgressHUD.dismiss()
                self.showAuthErrorAlert()
            }
        }
    }
}

// MARK: Extension AlertDelegate

extension SplashViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        self.present(alert, animated: true)
    }
    
    func showAuthErrorAlert() {
        
        let alert = AlertModel(
            title: "Что-то пошло не так(",
            message: "Не удалось войти в систему",
            buttonText: "OK")
        
        alertPresenter = AlertPresenter(alertDelegate: self)
        alertPresenter?.presentAlertController(alert: alert)
        
    }
    
}
