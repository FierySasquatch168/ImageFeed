//
//  UIVIew+Extensions.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 01.03.2023.
//

import UIKit

extension UIView {
    func addGradient(frame: CGRect, cornerRadius: CGFloat) {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.masksToBounds = true
        gradientLayer.frame = frame
        self.layer.cornerRadius = cornerRadius
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "locations")
        gradientChangeAnimation.duration = 2.0
        gradientChangeAnimation.repeatCount = .infinity
        gradientChangeAnimation.fromValue = [0, 0.1, 0.3]
        gradientChangeAnimation.toValue = [0, 0.8, 1]
        gradientLayer.add(gradientChangeAnimation, forKey: "locations")
        
        layer.addSublayer(gradientLayer)
        layoutSubviews()
    }
    
    func removeGradient() {
        layer.sublayers?.removeAll()
    }
}
