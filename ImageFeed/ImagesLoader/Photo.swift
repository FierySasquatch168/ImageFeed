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
}
