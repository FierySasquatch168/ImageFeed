//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.02.2023.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imagesListVC = ImagesListViewController()
        let imagesListPresenter = ImagesListPresenter(imagesHelper: ImagesHelper())
        imagesListVC.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListVC
        
        let navVC = CustomNavigationController(rootViewController: imagesListVC)
        navVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_editorial_active"), tag: 0)
        navVC.navigationBar.isHidden = true

        let profileVC = ProfileViewController()
        let profilePresenter = ProfilePresenter(logoutHelper: LogoutHelper())
        profileVC.presenter = profilePresenter
        profilePresenter.view = profileVC
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: "tab_profile_active"), tag: 1)
        
        UITabBar.appearance().tintColor = .ypWhite
        UITabBar.appearance().barTintColor = .ypBlack
        UITabBar.appearance().isTranslucent = false
        
        self.viewControllers = [navVC, profileVC]
    }
}
