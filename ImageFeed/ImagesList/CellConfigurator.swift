//
//  CellConfiguratorHelper.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.03.2023.
//

import UIKit

protocol CellConfiguratorProtocol {
    func setupDataLabelText(for indexPath: IndexPath, at photos: [Photo]) -> String
    func isLiked(for indexPath: IndexPath, at photos: [Photo]) -> Bool
    func chooseCellSelectionStyle(for cell: ImagesListCell) -> UITableViewCell.SelectionStyle
    func calculateCellHeight(_ tableView: UITableView, at indexPath: IndexPath, with photos: [Photo]) -> CGFloat
}


final class CellConfigurator: CellConfiguratorProtocol {
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func setupDataLabelText(for indexPath: IndexPath, at photos: [Photo]) -> String {
        guard let date = photos[indexPath.row].createdAt else { return "Date error" }
        return self.dateFormatter.string(from: date)
    }
    
    func isLiked(for indexPath: IndexPath, at photos: [Photo]) -> Bool {
        return photos[indexPath.row].isLiked
    }
    
    func chooseCellSelectionStyle(for cell: ImagesListCell) -> UITableViewCell.SelectionStyle {
        return .none
    }
    
    func calculateCellHeight(_ tableView: UITableView, at indexPath: IndexPath, with photos: [Photo]) -> CGFloat {
        if photos.count == 0 { return 0 }
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}
