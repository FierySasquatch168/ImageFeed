//
//  ImagesListPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImageFeed.ImagesListViewControllerProtocol?
    
    var photos: [ImageFeed.Photo] = []
    var imagesLoaderObserver: NSObjectProtocol?
    
    var viewDidLoadCalled: Bool = false
    var updatePhotosArrayCalled: Bool = false
    var updateNextPageIfNeededCalled: Bool = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updatePhotosArray() {
        updatePhotosArrayCalled = true
    }
    
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath) {
        updateNextPageIfNeededCalled = true
    }
    
}
