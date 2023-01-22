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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
        let navVC = UINavigationController(rootViewController: ImagesListViewController())
        let tabbarVC = UITabBarController()
        UITabBar.appearance().tintColor = .ypWhite
        tabbarVC.viewControllers = [navVC, ProfileViewController()]
        tabbarVC.modalPresentationStyle = .fullScreen
        
        self.present(tabbarVC, animated: true)
    }
    
    private func switchToAuthViewController() {
        let nextVC = AuthViewController()
        nextVC.authViewControllerDelegate = self
        
        let navVC = UINavigationController(rootViewController: nextVC)
        navVC.modalPresentationStyle = .fullScreen
         
        self.present(navVC, animated: true)
    }
    
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print("SplashViewController authViewController works 1")
        dismiss(animated: true) { [weak self] in
            print("SplashViewController authViewController dismiss works")
            guard let self = self else {
                print("SplashViewController authViewController self is nil")
                return
            }
            print("SplashViewController authViewController self is not nil")
            print(code)
            self.fetchOAuthToker(code: code)
        }
    }
    
    private func fetchOAuthToker(code: String) {
        print("SplashViewController fetchOAuthToker works 1")
        oAuth2Service.fetchAuthToken(code: code, completion: { result in
            print("SplashViewController fetchOAuthToker works 2")
            switch result {
            case .success:
                print("SplashViewController fetchOAuthToker result has data")
                self.switchToTabBarController()
            case .failure:
                print("SplashViewController fetchOAuthToker result has no data")
                break
            }
        })
    }
    
    
}
