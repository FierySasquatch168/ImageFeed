//
//  LogoutHelper.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 03.03.2023.
//

import UIKit

protocol LogoutHelperProtocol {
    func logout()
}

final class LogoutHelper: LogoutHelperProtocol {
    
    func logout() {
        clearToken()
        clearUserDataFromMemory()
        processToSplashScreen()
    }
    
    private func clearToken() {
        // хранилище - удалить токен
        OAuth2TokenStorage().token = nil
    }
    
    private func clearUserDataFromMemory() {
        // вебвью - удалить куки
        WebViewViewController.clean()
    }
    
    private func processToSplashScreen() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        window.rootViewController = SplashViewController()
    }
    
    
}
