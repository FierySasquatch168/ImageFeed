//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.12.2022.
//

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    private var imagesListService = ImagesListService.shared
    private var imagesLoaderObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private var photos: [Photo] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypBlack
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var dateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupTableView()
        setNotificationObserver()
        imagesListService.fetchPhotosNextPage()
        
    }
    
    // MARK: Observer
    private func setNotificationObserver() {
        imagesLoaderObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.updateTableViewAnimated()
        }
    }
   
    
    // MARK: Behaviour
    
    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let url = URL(string: photos[indexPath.row].thumbImageURL),
              let date = photos[indexPath.row].createdAt,
              let stubImage = UIImage(named: "Stub")
        else {
            return
        }
            cell.mainImage.kf.setImage(
                with: url, placeholder: stubImage) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success(_):
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    case .failure(let error):
                        print(error)
                    }
                }
            cell.dateLabel.text = self.dateFormatter.string(from: date)
            cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
    }
    
    private func updateTableViewAnimated() {
        let oldCount = self.photos.count
        let newCount = ImagesListService.shared.photos.count
        photos = ImagesListService.shared.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).compactMap { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    // MARK: Style

    private func setupTableView() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

}

// MARK: Extension TableView

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        guard let fullImageURL = URL(string: photos[indexPath.row].fullImageURL) else { return }
        singleImageVC.fullImageURL = fullImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        self.present(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == ImagesListService.shared.photos.count-1 {
            ImagesListService.shared.fetchPhotosNextPage()
        }
    }
    
}

// MARK: Extension cell delegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
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
                        // Dismiss the loader
                        UIBlockingProgressHUD.dismiss()
                    }
                    
                case .failure(_):
                    UIBlockingProgressHUD.dismiss()
                    // TODO: Show alert
                    self.showLikeErrorAlert()
            }
        }
    }
}

// MARK: Extension AlertDelegate

extension ImagesListViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        self.present(alert, animated: true)
    }
    
    func showLikeErrorAlert() {
        
        let alert = AlertModel(
            title: "Ошибка",
            message: "Действие временно недоступно, попробуйте позднее",
            buttonText: "OK")
        
        alertPresenter = AlertPresenter(alertDelegate: self)
        alertPresenter?.presentAlertController(alert: alert)
        
    }
}
