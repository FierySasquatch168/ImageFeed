//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 30.12.2022.
//

import UIKit

final class SingleImageViewController: UIViewController {
    
    var fullImageURL: URL?
    private var alertPresenter: AlertPresenterProtocol?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .ypBlack
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        return button
    }()
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        scrollView.bounces = true
        
        return scrollView
    }()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScrollView()
        setupImageView()
        setupDismissButton()
        setupShareButton()
        
        showFullImage()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerImage()
    }
    
    // MARK: @OBJC
    
    @objc private func dismissButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapShareButton() {
        let share = UIActivityViewController(
            activityItems: [imageView.image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    // MARK: Behaviour
    
    func showFullImage() {
        guard let fullImageURL = fullImageURL else { return }
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(
            with: fullImageURL) { [weak self] result in
                UIBlockingProgressHUD.dismiss()
                guard let self = self else { return }
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        self.centerImage()
                    }
                case .failure(_):
                    self.showFullPhotoAlert()
                }
            }
    }
    
    // Centering the image in ScrollView via frameToCenter according to scrollView bounds
    func centerImage() {
        let boundsSize = scrollView.bounds.size
        var frameToCenter = imageView.frame
        
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        
        imageView.frame = frameToCenter
    }
    
    // MARK: Style
        
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.frame = view.bounds
    }
    
    private func setupImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

    }
    
    private func setupDismissButton() {
        view.addSubview(dismissButton)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        dismissButton.setImage(UIImage(named: "Backward"), for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
                
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            dismissButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            dismissButton.heightAnchor.constraint(equalToConstant: 48),
            dismissButton.widthAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func setupShareButton() {
        view.addSubview(shareButton)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        shareButton.setImage(UIImage(named: "Sharing"), for: .normal)
        shareButton.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            shareButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -36)
        ])
    }
    
    
}

// MARK: Extension ScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

// MARK: Extension AlertDelegate

extension SingleImageViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        self.present(alert, animated: true)
    }
    
    func showFullPhotoAlert() {
        let alert = AlertModel(
            title: "Ошибка загрузки",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            buttonText: "Не нужно",
            actionText: "Повторить") { [weak self] _ in
                guard let self = self else { return }
                self.showFullImage()
            }
        
        alertPresenter = AlertPresenter(alertDelegate: self)
        alertPresenter?.presentAlertController(alert: alert)
    }
}
