//
//  UINavigationController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 22.01.2023.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }
}

extension UserDefaults {
    static func resetDefaults ( ) {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
