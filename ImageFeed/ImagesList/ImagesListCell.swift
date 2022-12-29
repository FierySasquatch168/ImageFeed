//
//  TableViewCell.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.12.2022.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    
    var mainImage = UIImageView()
    var dateLabel = UILabel()
    var likeButton = UIButton()
    var gradientView = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        configureMainImage()
        configureLikeButton()
        
        configureGradientView()
        configureDateLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gradient override
    
    override func layoutSubviews() {
        let layer = CAGradientLayer()
        
        layer.colors = [
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 0).cgColor,
            UIColor(red: 0.102, green: 0.106, blue: 0.133, alpha: 1).cgColor
        ]
        
        layer.locations = [0,1]
        layer.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 0.54, c: -0.54, d: 0, tx: 0.77, ty: 0))
        layer.frame = gradientView.bounds
        layer.cornerRadius = 30
        
        gradientView.layer.addSublayer(layer)
    }
    
    // MARK: UI Configuration
    
    private func configureMainImage() {
        addSubview(mainImage)
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        
        mainImage.layer.cornerRadius = 16
        mainImage.layer.masksToBounds = true
        mainImage.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate([
            mainImage.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            mainImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
            mainImage.leadingAnchor.constraint(equalTo: leadingAnchor),
            mainImage.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureDateLabel() {
        addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dateLabel.textColor = .white
        
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: mainImage.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: mainImage.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureLikeButton() {
        addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: mainImage.topAnchor, constant: 12),
            likeButton.trailingAnchor.constraint(equalTo: mainImage.trailingAnchor, constant: -10.5)
        ])
    }
    
    private func configureGradientView() {
        addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: mainImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: mainImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: mainImage.bottomAnchor),
            gradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
