//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 04.03.2023.
//

import UIKit

protocol ImagesListPresenterProtocol {
//    var view: ImagesListViewControllerProtocol? { get set }
    
    // showing photos in tableView
    var photos: [Photo] { get set }
    func loadNextPage()
    func updateNextPageIfNeeded(_ tableView: UITableView, forRowAt indexPath: IndexPath)
    func checkForNeedOfAnimatedUpdate()
    
    // configuring cells of tableView
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat
    func changeLike(_ cell: ImagesListCell, at indexPath: IndexPath)
    
    // dateFormatting
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var photos: [Photo] = []
    
    private var imagesListService = ImagesListService.shared
    var view: ImagesListViewControllerProtocol
    
    init(view: ImagesListViewControllerProtocol) {
        self.view = view
    }
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    func loadNextPage() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let url = URL(string: photos[indexPath.row].thumbImageURL),
              let date = photos[indexPath.row].createdAt,
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
        cell.dateLabel.text = self.dateFormatter.string(from: date)
        cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
        cell.selectionStyle = .none
    }
    
    func getCellHeight(_ tableView: UITableView, at indexPath: IndexPath) -> CGFloat {
        if photos.count == 0 {
            return 0
        }
        
        let imageWidth = photos[indexPath.row].size.width
        let imageHeight = photos[indexPath.row].size.height
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func updateNextPageIfNeeded(_ tableView: UITableView, forRowAt indexPath: IndexPath) {
        if indexPath.row == imagesListService.photos.count-1 {
            loadNextPage()
        }
    }
    
    func changeLike(_ cell: ImagesListCell, at indexPath: IndexPath) {
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
    
    func checkForNeedOfAnimatedUpdate() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        self.photos = imagesListService.photos
        print("ImagesListPresenter checkForNeedOfAnimatedUpdate oldCount is \(oldCount), newCount is \(newCount)")
        
        if oldCount != newCount {
            print("ImagesListPresenter view is: \(view)")
            view.didReceivePhotosForTableViewAnimatedUpdate(from: oldCount, to: newCount)
            print("checkForNeedOfAnimatedUpdate finished work")
        }
    }
}
