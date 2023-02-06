//
//  Profile.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 02.02.2023.
//

import Foundation

struct Profile: Decodable {
    let username: String?
    let name: String?
    let loginName: String?
    let bio: String?
}
