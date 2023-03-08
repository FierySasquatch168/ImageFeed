//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import Foundation

protocol ImagesListPresenterProtocol {
    var imagesHelper: ImagesHelperProtocol { get set }
    func viewDidLoad()
    // info for cell configuration
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
    func updateNextPageIfNeeded(forRowAt indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var photos: [Photo] = []
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    private var imagesLoaderObserver: NSObjectProtocol?
    var view: ImagesListViewControllerProtocol
    var imagesHelper: ImagesHelperProtocol
    
    init(view: ImagesListViewControllerProtocol, imagesHelper: ImagesHelperProtocol) {
        self.view = view
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
    
    // MARK: Work with photo
    
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
        self.photos = imagesHelper.returnModelPhotos()
    }
    
    func getDateLabelText(at indexPath: IndexPath) -> String {
        guard let date = photos[indexPath.row].createdAt else { return "Date error in getDateLabelText" }
        return dateFormatter.string(from: date)
    }
    
    func isLiked(at indexPath: IndexPath) -> Bool {
        return photos[indexPath.row].isLiked
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
            view.didReceivePhotosForTableViewAnimatedUpdate(at: indexPaths)
        }
    }
    
    private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
        return (oldCount..<newCount).compactMap { i in
            IndexPath(row: i, section: 0)
        }
    }
}
