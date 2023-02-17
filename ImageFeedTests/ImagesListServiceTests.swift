//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import XCTest
@testable import ImageFeed

final class ImageFeedTests: XCTestCase {
    
    func testFetchPhotos() {
        let service = ImagesListService()
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { _ in
                expectation.fulfill()
            }
        service.fetchPhotosNextPage(with: OAuth2Service.shared.authToken)
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
       
    }
}
