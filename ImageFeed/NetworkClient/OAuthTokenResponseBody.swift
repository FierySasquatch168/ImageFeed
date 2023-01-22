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
    
    enum SnakeCaseKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}

struct User: Encodable {
    let username: String
}
