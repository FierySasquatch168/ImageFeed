//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 02.02.2023.
//

import Foundation

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private(set) var avatarURL: String?
    private var oAuth2Service = OAuth2Service.shared
    private var task: URLSessionTask?
    
    struct UserResult: Codable {
        let profileImage: ImageSize
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
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
        let task = URLSession.shared.data(for: urlRequest) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let imagePack = try? JSONDecoder().decode(UserResult.self, from: data) else { return }
                let smallImage = imagePack.profileImage.small
                self.avatarURL = smallImage
                completion(.success(smallImage))
            }
        }
        
        task.resume()
        
    }
    
    func makeImageRequest(username: String) -> URLRequest? {
        var urlRequest = URLRequest.makeHTTPRequest(
            path: "/users/"
            + "\(username)",
            httpMethod: "GET",
            baseURL: defaultBaseURL)
        
        guard let token = oAuth2Service.authToken else { return nil }
        
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return urlRequest
    }
}
