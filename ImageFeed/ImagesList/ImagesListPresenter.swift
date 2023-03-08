//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var imagesLoaderObserver: NSObjectProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func updatePhotosArray()
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath)
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    
    var imagesLoaderObserver: NSObjectProtocol?
    var view: ImagesListViewControllerProtocol?
    var imagesHelper: ImagesHelperProtocol
    
    init(imagesHelper: ImagesHelperProtocol) {
        self.imagesHelper = imagesHelper
    }
    
    func viewDidLoad() {
        setNotificationObserver()
        imagesHelper.loadNextPage()
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
    
    func updatePhotosArray() {
        self.photos = imagesHelper.returnModelPhotos()
    }
    
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesHelper.countModelPhotos() - 1 {
            imagesHelper.loadNextPage()
        }
    }
    
    // MARK: Class methods

    
    private func checkForNeedOfAnimatedUpdate() {
        let oldCount = countPhotos()
        let newCount = imagesHelper.countModelPhotos()
        
        if oldCount != newCount {
            updatePhotosArray()
            let indexPaths = createIndexPaths(from: oldCount, to: newCount)
            view?.didReceivePhotosForTableViewAnimatedUpdate(at: indexPaths)
        }
    }
    
    private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
        return (oldCount..<newCount).compactMap { i in
            IndexPath(row: i, section: 0)
        }
    }
}

// MARK: Extension PresenterProtocol

extension ImagesListPresenterProtocol {
    func getFullImageURL(for indexPath: IndexPath) -> URL? {
        return URL(string: photos[indexPath.row].fullImageURL)
    }
    
    func getThumbImageURL(for indexPath: IndexPath) -> URL? {
        return URL(string: photos[indexPath.row].thumbImageURL)
    }
    
    func countPhotos() -> Int {
        return photos.count
    }
    
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat {
        let imageSize = getImageSize(at: indexPath)
        let imageWidth = imageSize.width
        let imageHeight = imageSize.height
        
        let imageViewWidth = width - left - right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + top + bottom
        return cellHeight
    }
    
    func getPhoto(at indexPath: IndexPath) -> Photo {
        return photos[indexPath.row]
    }
    
    func getDateLabelText(at indexPath: IndexPath) -> String {
        guard let date = photos[indexPath.row].createdAt else { return "Date error in getDateLabelText" }
        return CustomDateFormatter().string(from: date)
    }
    
    func isLiked(at indexPath: IndexPath) -> Bool {
        return photos[indexPath.row].isLiked
    }
    
    func getImageSize(at indexPath: IndexPath) -> CGSize {
        let width = photos[indexPath.row].size.width
        let height = photos[indexPath.row].size.height
        return CGSize(width: width, height: height)
    }
}
