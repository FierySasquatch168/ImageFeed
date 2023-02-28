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
            guard let token = newValue else {
                keychainWrapper.removeObject(forKey: "token")
                return
            }
            let isSuccess = keychainWrapper.set(token, forKey: "token")
            guard isSuccess else {
                print("OAuth2TokenStorage token setting error")
                return
            }
        }
    }
}
