//
//  MockPhotos.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

struct MockPhotos {
    static let photos: [Photo] = [
        Photo(
            id: "1",
            size: CGSize(width: 100, height: 100),
            createdAt: Date(),
            welcomeDescription: "TestDescription1",
            thumbImageURL: "thumbImageURL1",
            largeImageURL: "largeImageURL1",
            fullImageURL: "fullImageURL1",
            isLiked: true),
        Photo(
            id: "2",
            size: CGSize(width: 200, height: 200),
            createdAt: Date(),
            welcomeDescription: "TestDescription2",
            thumbImageURL: "thumbImageURL2",
            largeImageURL: "largeImageURL2",
            fullImageURL: "fullImageURL2",
            isLiked: false),
        Photo(
            id: "3",
            size: CGSize(width: 300, height: 300),
            createdAt: Date(),
            welcomeDescription: "TestDescription3",
            thumbImageURL: "thumbImageURL3",
            largeImageURL: "largeImageURL3",
            fullImageURL: "fullImageURL3",
            isLiked: false),
        Photo(
            id: "4",
            size: CGSize(width: 400, height: 400),
            createdAt: Date(),
            welcomeDescription: "TestDescription4",
            thumbImageURL: "thumbImageURL4",
            largeImageURL: "largeImageURL4",
            fullImageURL: "fullImageURL4",
            isLiked: true),
    ]
}
