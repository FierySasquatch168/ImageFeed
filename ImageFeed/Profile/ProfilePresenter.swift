//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 03.03.2023.
//

import UIKit
import Kingfisher


protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func updateProfile(with profile: Profile?)
    func updateAvatar()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var logoutHelper: LogoutHelperProtocol?

    private var avatarCornerRadius: CGFloat = 35
    
    // MARK: Protocol methods
    
    func logout() {
        logoutHelper = LogoutHelper()
        logoutHelper?.logout()
    }
    
    func updateProfile(with profile: Profile?) {
        guard let profile = profile else { return }
        setupUserName(from: profile)
        setupUserEmail(from: profile)
        setupUserDescription(from: profile)
    }
    
    func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else {
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: avatarCornerRadius)
        view?.profileImage.kf.setImage(with: url, options: [.processor(processor)])
    }
    
    // MARK: Class methods
    
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

