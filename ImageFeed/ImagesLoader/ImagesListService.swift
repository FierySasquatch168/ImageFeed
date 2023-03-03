//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import UIKit

final class ImagesListService {
    static var shared = ImagesListService()
    private var alertPresenter: AlertPresenterProtocol?
    static let DidChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private var photosPerPage: Int = 10
    private (set) var photos: [Photo] = [] {
        didSet {
            NotificationCenter.default.post(
                name: ImagesListService.DidChangeNotification,
                object: self)
        }
    }
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private var tokenService = OAuth2Service.shared
    
    // MARK: Behavior
    
    func fetchPhotosNextPage() {
        guard let token = tokenService.authToken else { return }
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        if task != nil { return }
        lastLoadedPage = nextPage
                
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(nextPage)"
            + "&&per_page=\(photosPerPage)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL)
                
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                DispatchQueue.main.async {  [weak self] in
                    guard let self = self else { return }
                    let photos = self.convertFetchedModelToViewModel(model: photoResult)
                    self.photos += photos
                    self.task = nil
                }
            case .failure(let error):
                self.showErrorAlert(with: error)
                self.task = nil
                return
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: Like change
    func changeLike(photoId: String, isLiked: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = tokenService.authToken else { return }
        let method = isLiked ? "DELETE" : "POST"
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/photos/"
            + "\(photoId)/"
            + "like",
            httpMethod: method,
            baseURL: DefaultBaseURL)
                
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard let self = self else { return }
            if let error = error {
                self.showErrorAlert(with: error)
                completion(.failure(error))
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode < 200 || response.statusCode >= 300 {
                self.showErrorAlert(with: NetworkError.httpStatusCode(response.statusCode))
                completion(.failure(NetworkError.httpStatusCode(response.statusCode)))
            }
            
            if data != nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                    let photo = self.photos[index]
                    let newPhoto = Photo(
                        id: photo.id,
                        size: photo.size,
                        createdAt: photo.createdAt,
                        welcomeDescription: photo.welcomeDescription,
                        thumbImageURL: photo.thumbImageURL,
                        largeImageURL: photo.largeImageURL,
                        fullImageURL: photo.fullImageURL,
                        isLiked: !photo.isLiked)
                    
                        self.photos[index] = newPhoto
                    }
                }
                completion(.success(()))
            }
        }
        task.resume()
    }
    
    // MARK: Converting to viewModel
        
    func convertFetchedModelToViewModel(model: [PhotoResult]) -> [Photo] {
        var photos: [Photo] = []
        for i in 0..<model.count {
            let size = makePhotoSize(width: model[i].width, height: model[i].height)
            let photo = Photo(
                id: model[i].id,
                size: size,
                createdAt: model[i].createdAt,
                welcomeDescription: model[i].description,
                thumbImageURL: model[i].urls.thumb,
                largeImageURL: model[i].urls.regular,
                fullImageURL: model[i].urls.full,
                isLiked: model[i].likedByUser
            )
            photos.append(photo)
        }
        
        return photos
    }
    
    func makePhotoSize(width: Int, height: Int) -> CGSize {
        let itemWidth = Double(width)
        let itemHeight = Double(height)
        return CGSize(width: itemWidth, height: itemHeight)
    }
}

// MARK: Extension AlertDelegate

extension ImagesListService: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        UIApplication.topViewController()?.present(alert, animated: true)
    }
    
    func showErrorAlert(with error: Error) {
        
        let alert = AlertModel(
            title: "Ошибка",
            message: error.localizedDescription,
            buttonText: "OK")
        
        alertPresenter = AlertPresenter(alertDelegate: self)
        alertPresenter?.presentAlertController(alert: alert)
        
    }
}

