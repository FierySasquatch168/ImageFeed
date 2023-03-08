//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 03.03.2023.
//

import Foundation
import Kingfisher


protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var logoutHelper: LogoutHelperProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?
    private var profileService = ProfileService.shared
    private var profileImageService = ProfileImageService.shared
    private var avatarCornerRadius: CGFloat = 35
    
    // MARK: Protocol methods
    
    func viewDidLoad() {
        setNotificationObserver()
        updateProfile(with: profileService.profile)
        updateAvatar(with: profileImageService.avatarURL)
    }
    
    func logout() {
        logoutHelper = LogoutHelper()
        logoutHelper?.logout()
    }
    
    // MARK: Class methods
    
    private func setNotificationObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar(with: self.profileImageService.avatarURL)
        }
    }
    
    private func updateProfile(with profile: Profile?) {
        guard let profile = profile else { return }
        setupUserName(from: profile)
        setupUserEmail(from: profile)
        setupUserDescription(from: profile)
    }
        
    private func updateAvatar(with stringUrl: String?) {
        let url = getProfileAvatarUrl(from: stringUrl)
        let processor = RoundCornerImageProcessor(cornerRadius: avatarCornerRadius)
        view?.profileImage.kf.setImage(with: url, options: [.processor(processor)])
    }
    
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

