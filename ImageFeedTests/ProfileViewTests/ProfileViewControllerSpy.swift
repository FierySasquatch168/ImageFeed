//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol?
    var setImageCalled: Bool = false
    var updateUserNameCalled: Bool = false
    var updateUserEmailCalled: Bool = false
    var updateUserdescriptionCalled: Bool = false
        
    func setImage(from url: URL?, with cornerRadius: CGFloat) {
        setImageCalled = true
    }
    
    func updateUserName(with name: String) {
        updateUserNameCalled = true
    }
    
    func updateUserEmail(with email: String) {
        updateUserEmailCalled = true
    }
    
    func updateUserdescription(with description: String) {
        updateUserdescriptionCalled = true
    }
    
    
}
