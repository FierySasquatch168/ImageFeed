//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var photos: [Photo] { get set }
    func loadNextPage()
    func setNotificationObserver()
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath)
    func getFullImageURL(for indexPath: IndexPath) -> URL?
    func countPhotos() -> Int
    func getImageHeight(at indexPath: IndexPath) -> CGFloat
    func getImageWidth(at indexPath: IndexPath) -> CGFloat
    func getPhoto(at indexPath: IndexPath) -> Photo
    func updatePhotosArray()
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    private var imagesListService = ImagesListService.shared
    private var imagesLoaderObserver: NSObjectProtocol?
    var view: ImagesListViewControllerProtocol
    
    init(view: ImagesListViewControllerProtocol) {
            self.view = view
        }
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func setNotificationObserver() {
        imagesLoaderObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
                guard let self = self else { return }
                self.checkForNeedOfAnimatedUpdate()
            }
    }
    
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count-1 {
            loadNextPage()
        }
    }
    
    func getFullImageURL(for indexPath: IndexPath) -> URL? {
        return URL(string: photos[indexPath.row].fullImageURL)
        
    }
    
    func getThumbImageURL(for indexPath: IndexPath) -> URL? {
        return URL(string: photos[indexPath.row].thumbImageURL)
    }
    
    func countPhotos() -> Int {
        return photos.count
    }
    
    func getImageHeight(at indexPath: IndexPath) -> CGFloat {
        return photos[indexPath.row].size.height
    }
    
    func getImageWidth(at indexPath: IndexPath) -> CGFloat {
        return photos[indexPath.row].size.width
    }
    
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        let imageWidth = getImageWidth(at: indexPath)
        let imageHeight = getImageHeight(at: indexPath)
        
        let imageViewWidth = width - left - right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + top + bottom
        return cellHeight
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func updatePhotosArray() {
        self.photos = imagesListService.photos
    }
    
    // MARK: Class methods
    
    private func checkForNeedOfAnimatedUpdate() {
            let oldCount = photos.count
            let newCount = imagesListService.photos.count
            
            if oldCount != newCount {
                updatePhotosArray()
                let indexPaths = createIndexPaths(from: oldCount, to: newCount)
                view.didReceivePhotosForTableViewAnimatedUpdate(at: indexPaths)
            }
        }
        
        
        
        private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
            return (oldCount..<newCount).compactMap { i in
                IndexPath(row: i, section: 0)
            }
        }
}
