//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.02.2023.
//

import UIKit

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: ((UIAlertAction) -> Void)?
}
