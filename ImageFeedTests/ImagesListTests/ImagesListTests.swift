//
//  ImagesListTests.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {

    func testViewControllerCallsPresenter() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterNotificationCentreNotNil() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        
        // when
        presenter.viewDidLoad()
        
        //then
        XCTAssertNotNil(presenter.imagesLoaderObserver)
    }
    
    func testPresenterCallsGetLabelText() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        let indexPath = IndexPath(row: 0, section: 0)
        let dateFormatter = CustomDateFormatter()
        
        presenter.photos = mockPhotos
        
        // when
        let text = presenter.getDateLabelText(at: indexPath)
        
        //then
        XCTAssertEqual(text, dateFormatter.string(from: Date()))
    }
    
    func testPresenterCallsGetFullImageUrl() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        let indexPath = IndexPath(row: 0, section: 0)
        
        presenter.photos = mockPhotos
        
        // when
        let fullIMageUrl = presenter.getFullImageURL(for: indexPath)?.absoluteString
        
        //then
        XCTAssertEqual(fullIMageUrl, mockPhotos[indexPath.row].fullImageURL)
    }
    
    func testPresenterCallsGetThumbImageUrl() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        let indexPath = IndexPath(row: 3, section: 0)
        
        presenter.photos = mockPhotos
        
        // when
        let thumbImageUrl = presenter.getThumbImageURL(for: indexPath)?.absoluteString
        
        //then
        XCTAssertEqual(thumbImageUrl, mockPhotos[indexPath.row].thumbImageURL)
    }
    
    func testPresenterCallsCountPhotos() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        
        presenter.photos = mockPhotos
        
        // when
        let mockPhotosCount = presenter.countPhotos()
        
        //then
        XCTAssertEqual(mockPhotosCount, mockPhotos.count)
    }
    
    func testPresenterCallsPhotoSize() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        let indexPath = IndexPath(row: 2, section: 0)
        
        presenter.photos = mockPhotos
        
        // when
        let mockSize = presenter.getImageSize(at: indexPath)
        
        //then
        XCTAssertEqual(mockSize, mockPhotos[indexPath.row].size)
    }
    
    
    func testPresenterCallsIsLiked() {
        // given
        let imagesHelper = ImagesHelper()
        let presenter = ImagesListPresenter(imagesHelper: imagesHelper)
        let mockPhotos = MockPhotos.photos
        let indexPath = IndexPath(row: 2, section: 0)
        
        presenter.photos = mockPhotos
        
        // when
        let isLiked = presenter.isLiked(at: indexPath)
        
        //then
        XCTAssertEqual(isLiked, mockPhotos[indexPath.row].isLiked)
    }
    
    
}
