//
//  CellConfiguratorHelper.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.03.2023.
//

import UIKit

protocol CellConfiguratorProtocol {
    var photos: [Photo] { get set }
    var presenterDelegate: CellConfiguratorDelegate? { get set }
    func configureCell(for cell: ImagesListCell, at indexPath: IndexPath)
    func calculateCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath)
}


final class CellConfigurator: CellConfiguratorProtocol {
    var photos: [Photo] = []
    weak var presenterDelegate: CellConfiguratorDelegate?
    private var imagesListService = ImagesListService.shared
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func configureCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        setupCellMainImage(for: cell, at: indexPath)
        setupDataLabelText(cell: cell, at: indexPath)
        isLiked(cell: cell, at: indexPath)
    }
    
    func calculateCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        if photos.count == 0 { return 0 }
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // Synchronize the arrays of photos
                    self.photos = self.imagesListService.photos
                    // Change the like image
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                }
                
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.presenterDelegate?.didGetErrorWhenChangingLike()
            }
        }
    }
    
    private func setupCellMainImage(for cell: ImagesListCell, at indexPath: IndexPath) {
        // TODO: move setIMage to CellConfigurator
        guard let url = URL(string: photos[indexPath.row].thumbImageURL),
              let stubImage = UIImage(named: "Stub")
        else {
            return
        }

        cell.mainImage.kf.setImage(with: url,
                                   placeholder: stubImage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.presenterDelegate?.didConfigureCellImage(at: indexPath)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setupDataLabelText(cell: ImagesListCell, at indexPath: IndexPath) {
        guard let date = photos[indexPath.row].createdAt else { return }
        cell.dateLabel.text = self.dateFormatter.string(from: date)
    }
    
    private func isLiked(cell: ImagesListCell, at indexPath: IndexPath) {
        let isLiked = photos[indexPath.row].isLiked
        cell.setIsLiked(isLiked: isLiked)        
    }
    
    
}
