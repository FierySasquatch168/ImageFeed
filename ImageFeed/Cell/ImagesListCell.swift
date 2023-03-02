//
//  TableViewCell.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.12.2022.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?
    
    lazy var mainImage = UIImageView()
    lazy var dateLabel = UILabel()
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    private lazy var dateGradientView: UIImageView = {
        var imageView = UIImageView()
        imageView.image = UIImage(named: "gradient")
        
        return imageView
    }()
    
    // MARK: Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        configureMainImage()
        configureDateGradientImageView()
        configureDateLabel()
        configureLikeButton()
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    // Guarantee that cells will use correct images
    override func prepareForReuse() {
        super.prepareForReuse()
        mainImage.kf.cancelDownloadTask()
        dateLabel.text = nil
        likeButton.imageView?.image = nil
        dateGradientView.image = nil
    }
    
    // MARK: Behaviour
    @objc private func likeButtonTapped() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    func setIsLiked(isLiked: Bool) {
        let liked = UIImage(named: "Active")
        let notLiked = UIImage(named: "No Active")
        isLiked ? likeButton.setImage(liked, for: .normal) : likeButton.setImage(notLiked, for: .normal)
    }
    
    // MARK: Style
    
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
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    private func configureLikeButton() {
        contentView.addSubview(likeButton)
        likeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10.5)
        ])
    }
    
    private func configureDateGradientImageView() {
        addSubview(dateGradientView)
        dateGradientView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateGradientView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateGradientView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateGradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            dateGradientView.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}
