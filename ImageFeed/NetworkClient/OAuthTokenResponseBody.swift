//
//  NetworkDataModel.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 20.01.2023.
//

import Foundation

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
    
    // MARK: Enum CodingKeys replaced by decoder KeyDecodingStrategy = .convertFromSnakeCase in URL+ Extensions
    
}

struct User: Encodable {
    let username: String
}
