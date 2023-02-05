//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import Foundation
import SwiftKeychainWrapper

class OAuth2TokenStorage {
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: "token")
        }
        set {
            guard let token = newValue else { return }
            let isSuccess = KeychainWrapper.standard.set(token, forKey: "token")
            guard isSuccess else {
                return
            }
        }
    }
}
