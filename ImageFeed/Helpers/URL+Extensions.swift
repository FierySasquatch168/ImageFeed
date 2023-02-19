//
//  URL+Extensions.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 21.01.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(path: String, httpMethod: String, baseURL: URL = defaultBaseURL) -> URLRequest {
        var request = URLRequest(url: URL(string: path, relativeTo: baseURL)!)
        request.httpMethod = httpMethod
        return request
    }
}

extension URLSession {    
    func objectTask<T: Decodable>(for request:  URLRequest, completion: @escaping (Result<T, Error>)-> Void) -> URLSessionTask {
        
        let fulfillmentCompletionOnMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    do {
//                        print("data=data, response=response, status code in 200..<300")
//                        print("Response is: \(response)")
//                        print("Status code is: \(statusCode)")
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        decoder.dateDecodingStrategy = .iso8601
                        let result = try decoder.decode(T.self, from: data)
                        fulfillmentCompletionOnMainThread(.success(result))
                    } catch {
//                        print("Caught error while useing decoder, error is: \(error)")
                        fulfillmentCompletionOnMainThread(.failure(error))
                    }
                } else {
//                    print("data != data or response != response, or status code !in 200..<300")
//                    print("Status code is: \(statusCode)")
                    fulfillmentCompletionOnMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
//                print("URL Request error")
                fulfillmentCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
//                print("Network error")
                fulfillmentCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        task.resume()
        return task
    }
}
