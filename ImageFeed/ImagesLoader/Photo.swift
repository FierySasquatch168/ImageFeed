//
//  Photo.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    func convertToViewModel(model: [PhotoResult]) -> [Photo] {
        var photos: [Photo] = []
        for i in 0..<model.count {
            let itemWidth = Double(model[i].width)!
            let itemHeight = Double(model[i].height)!
            let size = CGSize(width: itemWidth, height: itemHeight)
            let photo = Photo(
                id: model[i].id,
                size: size,
                createdAt: model[i].createdAt,
                welcomeDescription: model[i].description,
                thumbImageURL: model[i].urls.thumb,
                largeImageURL: model[i].urls.regular,
                isLiked: model[i].likedByUser
            )
            photos.append(photo)
        }
        
        return photos
    }
}
