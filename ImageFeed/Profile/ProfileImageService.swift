//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 02.02.2023.
//

import UIKit

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private var alertPresenter: AlertPresenterProtocol?
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var oAuth2Service = OAuth2Service.shared
    private var task: URLSessionTask?
    
    struct UserResult: Codable {
        let profileImage: ImageSize
        
        // MARK: Enum CodingKeys replaced by decoder KeyDecodingStrategy = .convertFromSnakeCase in URL+ Extensions
    }
    
    struct ImageSize: Codable {
        let small: String
        let medium: String
        let large: String
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>)-> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let urlRequest = makeImageRequest(username: username)
        
        guard let urlRequest = urlRequest else { return }
        let session = URLSession.shared
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.showErrorAlert(with: error)
                completion(.failure(error))
            case .success(let imagePack):
                let mediumImage = imagePack.profileImage.medium
                self.avatarURL = mediumImage
                completion(.success(mediumImage))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": mediumImage])
            }
        }
        
        task.resume()
        
    }
    
    func makeImageRequest(username: String) -> URLRequest? {
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/users/"
            + "\(username)",
            httpMethod: "GET",
            baseURL: DefaultBaseURL)
        
        guard let token = oAuth2Service.authToken else { return nil }
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return urlRequest
    }
}

extension ProfileImageService: AlertPresenterDelegate {
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
