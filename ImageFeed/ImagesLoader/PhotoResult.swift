//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import Foundation

struct PhotoResult: Decodable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let urls: UrlsResult
    
    // MARK: Enum CodingKeys replaced by decoder KeyDecodingStrategy = .convertFromSnakeCase in URL+ Extensions
 
}


