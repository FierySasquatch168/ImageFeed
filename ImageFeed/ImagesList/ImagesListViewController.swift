//
//  ViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.12.2022.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    func reloadTableView(at indexPath: IndexPath)
    func didReceivePhotosForTableViewAnimatedUpdate(from oldCount: Int, to newCount: Int)
    func likeChangeFailed()
}

final class ImagesListViewController: UIViewController & ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    private var imagesLoaderObserver: NSObjectProtocol?
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
        setNotificationObserver()
        
        presenter = ImagesListPresenter(view: self)
        presenter?.loadNextPage()
        
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
    
    func reloadTableView(at indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func likeChangeFailed() {
        self.showLikeErrorAlert()
    }
    
    private func updateTableViewAnimated() {
        presenter?.checkForNeedOfAnimatedUpdate()
    }
    
    func didReceivePhotosForTableViewAnimatedUpdate(from oldCount: Int, to newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).compactMap { i in
                IndexPath(row: i, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
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
        return presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        presenter?.configCell(for: cell, with: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let singleImageVC = SingleImageViewController()
        guard let photos = presenter?.photos,
              let fullImageURL = URL(string: photos[indexPath.row].fullImageURL) else { return }
        singleImageVC.fullImageURL = fullImageURL
        singleImageVC.modalPresentationStyle = .fullScreen
        self.present(singleImageVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return presenter?.getCellHeight(tableView, at: indexPath) ?? 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.updateNextPageIfNeeded(tableView, forRowAt: indexPath)
    }
    
}

// MARK: Extension cell delegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        UIBlockingProgressHUD.show()
        presenter?.changeLike(cell, at: indexPath)
        UIBlockingProgressHUD.dismiss()
            
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
