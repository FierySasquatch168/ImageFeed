//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import UIKit

final class ImagesListService {
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
    
    func fetchPhotosNextPage() {
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        task?.cancel()
        
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(nextPage)"
            + "&&per_page=\(photosPerPage)",
            httpMethod: "GET",
            baseURL: defaultBaseURL)
        
        let session = URLSession.shared
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                DispatchQueue.main.async {
                    let photos = self.convertToViewModel(model: photoResult)
                    self.photos += photos
                    self.task = nil
                }
            case .failure(let error):
                print(error)
                self.task = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func convertToViewModel(model: [PhotoResult]) -> [Photo] {
        var photos: [Photo] = []
        for i in 0..<model.count {
            let itemWidth = Double(model[i].width)!
            let itemHeight = Double(model[i].height)!
            let size = CGSize(width: itemWidth, height: itemHeight)
            let photo = Photo(
                id: model[i].id,
                size: size,
                createdAt: model[i].createdAt,
                welcomeDescription: model[i].description,
                thumbImageURL: model[i].urls.thumb,
                largeImageURL: model[i].urls.regular,
                isLiked: model[i].likedByUser
            )
            photos.append(photo)
        }
        
        return photos
    }
}
