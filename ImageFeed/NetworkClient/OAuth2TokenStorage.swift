//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import Foundation

class OAuth2TokenStorage {
    
    private var userDefaults = UserDefaults.standard
    
    var token: String? {
        get {
            return userDefaults.string(forKey: "token")
        }
        set {
            userDefaults.set(newValue, forKey: "token")
        }
    }
}
