//
//  WebViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 03.03.2023.
//

@testable import ImageFeed
import Foundation

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: ImageFeed.WebViewPresenterProtocol?
    var loadCalled: Bool = false
    
    func load(request: URLRequest) {
        loadCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
