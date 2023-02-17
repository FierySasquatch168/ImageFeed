//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 17.02.2023.
//

import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
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
    
    func fetchPhotosNextPage(with token: String?) {
        guard let token = token else { return }
        let nextPage = lastLoadedPage == nil ? 1 : (lastLoadedPage ?? 0) + 1
        task?.cancel()
        
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(nextPage)"
            + "&&per_page=\(photosPerPage)",
            httpMethod: "GET",
            baseURL: defaultBaseURL)
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let photoResult):
                DispatchQueue.main.async {
                    let photos = self.convertFetchedModelToViewModel(model: photoResult)
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
    
    func convertFetchedModelToViewModel(model: [PhotoResult]) -> [Photo] {
        var photos: [Photo] = []
        for i in 0..<model.count {
            let size = makePhotoSize(width: model[i].width, height: model[i].height)
            let date = convertStringToDate(string: model[i].createdAt)
            let photo = Photo(
                id: model[i].id,
                size: size,
                createdAt: date,
                welcomeDescription: model[i].description,
                thumbImageURL: model[i].urls.thumb,
                largeImageURL: model[i].urls.regular,
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
    
    func convertStringToDate(string: String?) -> Date? {
        guard let string = string else { return nil }
        let dateFormatter = DateFormatter()
        return dateFormatter.date(from: string)
    }
    
}
