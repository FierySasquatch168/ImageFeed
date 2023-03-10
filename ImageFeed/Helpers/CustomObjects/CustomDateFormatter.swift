//
//  CustomDateFormatter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

import UIKit

class CustomDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateStyle = .long
        self.timeStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
