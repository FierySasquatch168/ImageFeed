//
//  LogoutHelperSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

final class LogoutHelperSpy: LogoutHelperProtocol {
    var logoutCalled: Bool = false
    
    func logout() {
        logoutCalled = true
    }
    
}
