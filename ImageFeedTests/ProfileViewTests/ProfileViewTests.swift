//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    
    func testViewControllerCallsPresenter() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.setNotificationObserverCalled)
        XCTAssertTrue(presenter.updateProfileCalled)
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(logoutHelper: LogoutHelperSpy())
        let string = ProfileImageService.shared.avatarURL
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.updateAvatar(with: string)
        
        //then
        XCTAssertTrue(viewController.setImageCalled)
    }
    
    func testPresenterCallsUpdateProfile() {
        // given
        let viewController = ProfileViewControllerSpy()
        let presenter = ProfilePresenter(logoutHelper: LogoutHelperSpy())
        let profile = Profile(username: "", name: "", loginName: "", bio: "")
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        presenter.updateProfile(with: profile)
        
        //then
        XCTAssertTrue(viewController.updateUserNameCalled)
        XCTAssertTrue(viewController.updateUserEmailCalled)
        XCTAssertTrue(viewController.updateUserdescriptionCalled)
    }
    
    func testPresenterCallsLogout() {
        // given
        let logoutHelper = LogoutHelperSpy()
        let presenter = ProfilePresenter(logoutHelper: logoutHelper)
        
        // when
        presenter.logout()
        
        //then
        XCTAssertTrue(logoutHelper.logoutCalled)
    }
}
