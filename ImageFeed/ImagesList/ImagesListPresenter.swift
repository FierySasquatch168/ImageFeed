//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {    
    // showing photos in tableView
    func loadNextPage()
    func setNotificationObserver()
    func countPhotos() -> Int
    func updateNextPageIfNeeded(_ tableView: UITableView, forRowAt indexPath: IndexPath)
    func getFullImageURL(for indexPath: IndexPath) -> URL?
    
    // configuring cells of tableView
    func configCell(for cell: ImagesListCell, at indexPath: IndexPath)
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath)
    
}

protocol CellConfiguratorDelegate: AnyObject {
    func didConfigureCellImage(at indexPath: IndexPath)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    private var imagesLoaderObserver: NSObjectProtocol?
    private var imagesListService = ImagesListService.shared
    var view: ImagesListViewControllerProtocol
    var cellConfigurator: CellConfiguratorProtocol
    
    init(view: ImagesListViewControllerProtocol, cellConfigurator: CellConfiguratorProtocol) {
        self.view = view
        self.cellConfigurator = cellConfigurator
    }
    
    // MARK: Protocol methods
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func updateNextPageIfNeeded(_ tableView: UITableView, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count-1 {
            loadNextPage()
        }
    }
    
    func getFullImageURL(for indexPath: IndexPath) -> URL? {
        return URL(string: cellConfigurator.photos[indexPath.row].fullImageURL)
        
    }
    
    func setNotificationObserver() {
        imagesLoaderObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.checkForNeedOfAnimatedUpdate()
        }
    }
    
    func countPhotos() -> Int {
        return cellConfigurator.photos.count
    }
    
    // MARK: Cell configurator
    func configCell(for cell: ImagesListCell, at indexPath: IndexPath) {
        cellConfigurator.configureCell(for: cell, at: indexPath)
    }
    
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return cellConfigurator.calculateCellHeight(tableView, at: indexPath)
    }
    
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = cellConfigurator.photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success():
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // Synchronize the arrays of photos
                    self.cellConfigurator.photos = self.imagesListService.photos
                    // Change the like image
                    cell.setIsLiked(isLiked: self.cellConfigurator.photos[indexPath.row].isLiked)
                    UIBlockingProgressHUD.dismiss()
                }
                
            case .failure(_):
                UIBlockingProgressHUD.dismiss()
                self.view.likeChangeFailed()
            }
        }
    }
    
    // MARK: Class methods
    
    private func checkForNeedOfAnimatedUpdate() {
        let oldCount = cellConfigurator.photos.count
        let newCount = imagesListService.photos.count
        
        if oldCount != newCount {
            updatePhotosArray()
            let indexPaths = createIndexPaths(from: oldCount, to: newCount)
            view.didReceivePhotosForTableViewAnimatedUpdate(at: indexPaths)
        }
    }
    
    private func updatePhotosArray() {
        self.cellConfigurator.photos = imagesListService.photos
    }
    
    private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
        return (oldCount..<newCount).compactMap { i in
            IndexPath(row: i, section: 0)
        }
    }
    
}

extension ImagesListPresenter: CellConfiguratorDelegate {
    func didConfigureCellImage(at indexPath: IndexPath) {
        self.view.reloadTableView(at: indexPath)
    }
}
