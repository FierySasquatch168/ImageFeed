//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 02.02.2023.
//

import UIKit

final class ProfileService {
    
    static let shared = ProfileService()
    private var alertPresenter: AlertPresenterProtocol?
    
    struct ProfileResult: Decodable {
        let username: String?
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?

    func fetchProfile(token: String?, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let urlRequest = profileRequest(token: token)
        guard let urlRequest = urlRequest else { return }
        let session = URLSession.shared
        
        let task = session.objectTask(for: urlRequest) { [weak self] (result: Result<ProfileResult, Error>) in // extension for URLSession provides this request in MainThread
            guard let self = self else {
                return
            }
            switch result {
            case .failure(let error):
                self.showErrorAlert(with: error)
                completion(.failure(error))
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name: "\(profileResult.firstName ?? "") \(profileResult.lastName ?? "")",
                    loginName: profileResult.username != nil ? "@\(profileResult.username!)" : "",
                    bio: profileResult.bio
                )
                                
                self.profile = profile
                completion(.success(profile))
            }
        }
        task.resume()
    }
    
    private func profileRequest(token: String?) -> URLRequest? {
        guard let token = token else { return nil }
            var urlRequest = URLRequest.makeHTTPRequest(
                path: "/me",
                httpMethod: "GET",
                baseURL: defaultBaseURL)
                
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
}

// MARK: Extension AlertDelegate

extension ProfileService: AlertPresenterDelegate {
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

