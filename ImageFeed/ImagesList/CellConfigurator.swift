//
//  CellConfiguratorHelper.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.03.2023.
//

import Foundation

protocol ImagesHelperProtocol {
    var photos: [Photo] { get set }
    func getFullImageURL(for indexPath: IndexPath) -> URL?
    func getThumbImageURL(for indexPath: IndexPath) -> URL?
    func countPhotos() -> Int
    func getImageHeight(at indexPath: IndexPath) -> CGFloat
    func getImageWidth(at indexPath: IndexPath) -> CGFloat
    func getCellHeight(at indexPath: IndexPath, width: CGFloat, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) -> CGFloat
    func getPhoto(at indexPath: IndexPath) -> Photo
    func updatePhotosArray()
    func getDateLabelText(at indexPath: IndexPath) -> String
    func isLiked(at indexPath: IndexPath) -> Bool 
}

final class ImagesHelper: ImagesHelperProtocol {
    
    private var imagesListService = ImagesListService.shared
    
    var photos: [Photo] = []
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
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
    
    func getDateLabelText(at indexPath: IndexPath) -> String {
        guard let date = photos[indexPath.row].createdAt else { return "Date error in getDateLabelText" }
        return dateFormatter.string(from: date)
    }
    
    func isLiked(at indexPath: IndexPath) -> Bool {
        return photos[indexPath.row].isLiked
    }
    
    
}
