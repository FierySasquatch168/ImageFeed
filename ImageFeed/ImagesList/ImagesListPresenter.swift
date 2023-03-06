//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {    
    // showing photos in tableView
    var photos: [Photo] { get set }
    func loadNextPage()
    func setNotificationObserver()
    func updateNextPageIfNeeded(_ tableView: UITableView, forRowAt indexPath: IndexPath)
    func getFullImageURL(for indexPath: IndexPath) -> URL?
    
    // configuring cells of tableView
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath)
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var photos: [Photo] = []
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
        return URL(string: photos[indexPath.row].fullImageURL)
        
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
    
    // MARK: Cell configurator
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
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
                self.view.reloadTableView(at: indexPath)
            case .failure(let error):
                print(error)
            }
        }
        
        cell.dateLabel.text = cellConfigurator.setupDataLabelText(for: indexPath, at: self.photos)
        let isLiked = cellConfigurator.isLiked(for: indexPath, at: self.photos)
        cell.setIsLiked(isLiked: isLiked)
        cell.selectionStyle = cellConfigurator.chooseCellSelectionStyle(for: cell)
    }
    
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        return cellConfigurator.calculateCellHeight(tableView, at: indexPath, with: self.photos)
    }
    
    
    
    func didTapLikeButton(_ cell: ImagesListCell, at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
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
                }
                
            case .failure(_):
                self.view.likeChangeFailed()
            }
        }
    }
    
    // MARK: Class methods
    
    private func checkForNeedOfAnimatedUpdate() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        
        if oldCount != newCount {
            updatePhotosArray()
            let indexPaths = createIndexPaths(from: oldCount, to: newCount)
            view.didReceivePhotosForTableViewAnimatedUpdate(at: indexPaths)
        }
    }
    
    private func updatePhotosArray() {
        self.photos = imagesListService.photos
    }
    
    private func createIndexPaths(from oldCount: Int, to newCount: Int) -> [IndexPath] {
        return (oldCount..<newCount).compactMap { i in
            IndexPath(row: i, section: 0)
        }
    }
    
}
