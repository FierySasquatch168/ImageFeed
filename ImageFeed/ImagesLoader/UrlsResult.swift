//
//  UrlsResult.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import Foundation

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}
