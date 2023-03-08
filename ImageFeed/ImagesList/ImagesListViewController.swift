//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.12.2022.
//

import UIKit


protocol ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol? { get set }
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPaths: [IndexPath])
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    private var imagesListService = ImagesListService.shared
    private var alertPresenter: AlertPresenterProtocol?
    
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
    
    // MARK: Lifecycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypBlack
        setupTableView()
        presenter = ImagesListPresenter(view: self, imagesHelper: ImagesHelper())
        presenter?.setNotificationObserver()
        presenter?.loadNextPage()
    }
    
    // MARK: Protocol methods
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPaths: [IndexPath]) {
        tableView.performBatchUpdates {
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        
        setupCellMainImage(for: cell, at: indexPath)
        setupDataLabelText(cell: cell, at: indexPath)
        setupLikeImage(cell: cell, at: indexPath)
    }
    
    // MARK: Class methods
    
    private func setupCellMainImage(for cell: ImagesListCell, at indexPath: IndexPath) {
        guard let url = presenter?.getThumbImageURL(for: indexPath),
              let stubImage = UIImage(named: "Stub")
        else {
            return
        }

            cell.mainImage.kf.setImage(with: url,
                                       placeholder: stubImage) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                case .failure(let error):
                    cell.mainImage.image = stubImage
                    print(error)
                }
            }
        }
    
    private func setupDataLabelText(cell: ImagesListCell, at indexPath: IndexPath) {
        cell.dateLabel.text = presenter?.getDateLabelText(at: indexPath)
    }
    
    private func setupLikeImage(cell: ImagesListCell, at indexPath: IndexPath) {
        guard let isLiked = presenter?.isLiked(at: indexPath) else { return }
        cell.setIsLiked(isLiked: isLiked)
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
        return presenter?.countPhotos() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        configCell(for: cell, with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        singleImageVC.fullImageURL = presenter?.getFullImageURL(for: indexPath)
        singleImageVC.modalPresentationStyle = .fullScreen
        self.present(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard presenter?.countPhotos() != 0,
              let cellHeight = presenter?.getCellHeight(at: indexPath, width: tableView.bounds.width, left: 16, right: 16, top: 4, bottom: 4)
        else { return 0 }
        
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.updateNextPageIfNeeded(forRowAt: indexPath)
    }
    
}

// MARK: Extension cell delegate
extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let photo = presenter?.getPhoto(at: indexPath)
        else { return }
        
        UIBlockingProgressHUD.show()
            imagesListService.changeLike(photoId: photo.id, isLiked: photo.isLiked) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success():
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        // Synchronize the arrays of photos
                        self.presenter?.updatePhotosArray()
                        // Change the like image
                        if let isLiked = self.presenter?.isLiked(at: indexPath) {
                            cell.setIsLiked(isLiked: isLiked)
                        }
                        // Dismiss the loader
                        UIBlockingProgressHUD.dismiss()
                    }
                    
                case .failure(_):
                    UIBlockingProgressHUD.dismiss()
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
