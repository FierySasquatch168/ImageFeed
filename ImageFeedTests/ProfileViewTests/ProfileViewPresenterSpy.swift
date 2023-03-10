//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

final class ProfileViewPresenterSpy: ProfilePresenterProtocol {
    var profileImageServiceObserver: NSObjectProtocol?
    var view: ImageFeed.ProfileViewControllerProtocol?
    
    var setNotificationObserverCalled: Bool = false
    var updateProfileCalled: Bool = false
    var updateAvatarCalled: Bool = false
    var logoutCalled: Bool = false
    
    func setNotificationObserver() {
        setNotificationObserverCalled = true
    }
    
    func updateProfile(with profile: ImageFeed.Profile?) {
        updateProfileCalled = true
    }
    
    func updateAvatar(with stringUrl: String?) {
        updateAvatarCalled = true
    }
    func logout() {
        logoutCalled = true
    }
}
