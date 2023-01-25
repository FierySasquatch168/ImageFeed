//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import UIKit

class SplashViewController: UIViewController {

    private let oAuth2Service = OAuth2Service()
    private let oAuth2TokenStorage = OAuth2TokenStorage()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let token = oAuth2TokenStorage.token {
            switchToTabBarController()
        } else {
            switchToAuthViewController()
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        let navVC = CustomNavigationController(rootViewController: ImagesListViewController())
        navVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_editorial_active"), tag: 0)
        navVC.navigationBar.isHidden = true

        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_profile_active"), tag: 1)

        let tabbarVC = UITabBarController()
        UITabBar.appearance().tintColor = .ypWhite
        UITabBar.appearance().barTintColor = .ypBlack
        UITabBar.appearance().isTranslucent = false
        
        tabbarVC.viewControllers = [navVC, profileVC]
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
    
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.fetchOAuthToken(code: code)
        }
    }
    
    private func fetchOAuthToken(code: String) {
        oAuth2Service.fetchAuthToken(code: code, completion: { result in
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                break
            }
        })
    }
}
