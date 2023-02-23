//
//  AlertModel.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.02.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    var actionText: String? = nil
    var leftCompletion: ((UIAlertAction)-> Void)? = nil
    var rightCompletion: ((UIAlertAction) -> Void)? = nil
}
