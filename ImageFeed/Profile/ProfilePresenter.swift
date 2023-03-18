//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 03.03.2023.
//

import Foundation


protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileImageServiceObserver: NSObjectProtocol? { get set }
    func setNotificationObserver()
    func updateProfile(with profile: Profile?)
    func updateAvatar(with stringUrl: String?)
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var profileImageServiceObserver: NSObjectProtocol?
    private var profileImageService = ProfileImageService.shared
    private var avatarCornerRadius: CGFloat = 35
    
    var logoutHelper: LogoutHelperProtocol
    
    init(logoutHelper: LogoutHelperProtocol) {
        self.logoutHelper = logoutHelper
    }
    
    // MARK: Protocol methods
    
    func setNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar(with: self.profileImageService.avatarURL)
        }
    }
    
    func updateProfile(with profile: Profile?) {
        guard let profile = profile else { return }
        setupUserName(from: profile)
        setupUserEmail(from: profile)
        setupUserDescription(from: profile)
        view?.removeGradients()
    }
    
    func updateAvatar(with stringUrl: String?) {
        let url = getProfileAvatarUrl(from: stringUrl)
        view?.setImage(from: url, with: avatarCornerRadius)
    }
    
    func logout() {
        logoutHelper.logout()
    }
    
    // MARK: Class methods
    
    private func getProfileAvatarUrl(from string: String?) -> URL? {
        guard let string = string,
              let url = URL(string: string)
        else {
            return nil
        }
        return url
    }
    
    private func setupUserName(from profile: Profile) {
        view?.updateUserName(with: profile.name ?? "No name")
    }
    
    private func setupUserEmail(from profile: Profile) {
        view?.updateUserEmail(with: profile.username ?? "No username")
    }
    
    private func setupUserDescription(from profile: Profile) {
        view?.updateUserdescription(with: profile.bio ?? "No description")
    }
}

