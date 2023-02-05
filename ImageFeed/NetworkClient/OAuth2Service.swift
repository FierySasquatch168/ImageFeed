//
//  0Auth2Service.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 20.01.2023.
//

import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

final class OAuth2Service {
    
    static let shared = OAuth2Service()
    
    private var lastCode: String?
    private var task: URLSessionTask?
    private var urlSession = URLSession.shared
    
    private (set) var authToken: String? {
        get {
            return OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    func fetchAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if lastCode == code { return } ///Если lastCode != code, то мы должны всё-таки сделать новый запрос;
        task?.cancel() /// Старый запрос нужно отменить, но если task == nil, то ничего не будет выполнено, и мы просто пройдём дальше
        lastCode = code /// Запомнили code, использованный в запросе.
                    
        let request = authTokenRequest(code: code)
        let session = URLSession.shared
        
        let task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let body):
                let authToken = body.accessToken
                self.authToken = authToken
                completion(.success(authToken))
                self.task = nil
            case .failure(let error):
                completion(.failure(error))
                self.lastCode = nil
            }
        }
        self.task = task
        task.resume()
    }
    
    func authTokenRequest(code: String) -> URLRequest {
        
        // TODO: Rewrite the body using URLComponents func
        
        URLRequest.makeHTTPRequest(
            path: "/oauth/token"
            + "?client_id=\(accessKey)"
            + "&&client_secret=\(secretKey)"
            + "&&redirect_uri=\(redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            httpMethod: "POST",
            baseURL: URL(string: "https://unsplash.com")!)
    }
}
