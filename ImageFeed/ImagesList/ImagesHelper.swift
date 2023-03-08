//
//  CellConfiguratorHelper.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.03.2023.
//

import Foundation

protocol ImagesHelperProtocol {
    func loadNextPage()
    func countModelPhotos() -> Int
    func returnModelPhotos() -> [Photo]
}

final class ImagesHelper: ImagesHelperProtocol {
    private var imagesListService = ImagesListService.shared
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func countModelPhotos() -> Int {
        return imagesListService.photos.count
    }
    
    func returnModelPhotos() -> [Photo] {
        return imagesListService.photos
    }
    
}
