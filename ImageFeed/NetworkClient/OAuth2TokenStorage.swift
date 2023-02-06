//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    
    private var keychainWrapper = KeychainWrapper.standard
    
    var token: String? {
        get {
            keychainWrapper.string(forKey: "token")
        }
        set {
            guard let token = newValue else { return }
            let isSuccess = keychainWrapper.set(token, forKey: "token")
            guard isSuccess else {
                return
            }
        }
    }
}
