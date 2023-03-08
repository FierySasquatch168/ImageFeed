//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var imagesHelper: ImagesHelperProtocol { get set }
    func loadNextPage()
    func setNotificationObserver()
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath)
    func getFullImageURL(for indexPath: IndexPath) -> URL?
    func getThumbImageURL(for indexPath: IndexPath) -> URL?
    func countPhotos() -> Int
    func getImageHeight(at indexPath: IndexPath) -> CGFloat
    func getImageWidth(at indexPath: IndexPath) -> CGFloat
    func getPhoto(at indexPath: IndexPath) -> Photo
    func updatePhotosArray()
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat
    func getDateLabelText(at indexPath: IndexPath) -> String
    func isLiked(at indexPath: IndexPath) -> Bool
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    private var imagesListService = ImagesListService.shared
    private var imagesLoaderObserver: NSObjectProtocol?
    
    var view: ImagesListViewControllerProtocol
    var imagesHelper: ImagesHelperProtocol
    
    init(view: ImagesListViewControllerProtocol, imagesHelper: ImagesHelperProtocol) {
        self.view = view
        self.imagesHelper = imagesHelper
    }
    
    // MARK: Notification and pages loading
    
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
    
    // MARK: Work with photo
    
    func getFullImageURL(for indexPath: IndexPath) -> URL? {
        imagesHelper.getFullImageURL(for: indexPath)
        
    }
    
    func getThumbImageURL(for indexPath: IndexPath) -> URL? {
        imagesHelper.getThumbImageURL(for: indexPath)
    }
    
    func countPhotos() -> Int {
        imagesHelper.countPhotos()
    }
    
    func getImageHeight(at indexPath: IndexPath) -> CGFloat {
        imagesHelper.getImageHeight(at: indexPath)
    }
    
    func getImageWidth(at indexPath: IndexPath) -> CGFloat {
        imagesHelper.getImageWidth(at: indexPath)
    }
    
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        imagesHelper.getCellHeight(at: indexPath, width: width, left: left, right: right, top: top, bottom: bottom)
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        imagesHelper.getPhoto(at: indexPath)
    }
    
    func updatePhotosArray() {
        imagesHelper.updatePhotosArray()
    }
    
    func getDateLabelText(at indexPath: IndexPath) -> String {
        imagesHelper.getDateLabelText(at: indexPath)
    }
    
    func isLiked(at indexPath: IndexPath) -> Bool {
        imagesHelper.isLiked(at: indexPath)
    }
    
    // MARK: Class methods
    
    private func countModelPhotos() -> Int {
        return imagesListService.photos.count
    }
    
    private func checkForNeedOfAnimatedUpdate() {
            let oldCount = countPhotos()
            let newCount = countModelPhotos()
            
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
