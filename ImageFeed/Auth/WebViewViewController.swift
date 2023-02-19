//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 19.01.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {

    private let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var authDelegate: WebViewViewControllerDelegate?
    
    static func clean() {
        // Очищаем все куки из хранилища.
           HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
           // Запрашиваем все данные из локального хранилища.
           WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
              // Массив полученных записей удаляем из хранилища.
              records.forEach { record in
                 WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
              }
           }
    }
    
    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView()
        progress.tintColor = .ypBlack
        
        return progress
    }()
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        
        return webView
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        setupBackButton()
        setupURLComponents()
        setupProgressView()
        
        setupKVObserver()
        
    }
    // MARK: Observer setup
    
    private func setupKVObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    // MARK: Class methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url, /// Получаем из навигационного действия navigationAction URL
            let urlComponents = URLComponents(string: url.absoluteString), /// Получаем значения компонентов из URL
            urlComponents.path == "/oauth/authorize/native", /// Проверяем, совпадает ли адрес запроса с адресом получения кода
            let items = urlComponents.queryItems, /// Проверяем, есть ли в URLComponents компоненты запроса (в них должен быть код)
            let codeItem = items.first(where: { $0.name == "code" }) /// Ищем в массиве компонентов такой компонент, у которого значение name == code
        {
            
            return codeItem.value /// Если ок, возвращаем значение value найденного компонента
        } else {
            return nil /// Иначе возвращаем нил
        }
    }
    
    private func setupURLComponents() {
        var urlComponents = URLComponents(string: unsplashAuthorizeURLString)
        urlComponents?.queryItems = [
        URLQueryItem(name: "client_id", value: accessKey),
        URLQueryItem(name: "redirect_uri", value: redirectURI),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: accessScope)
        ]
        guard let url = urlComponents?.url else { return }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    @objc private func didTapBackButton() {
        authDelegate?.webViewViewControllerDidCancel(self)
    }
    
    // MARK: Setup UI
    
    private func setupProgressView() {
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupWebView() {
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBackButton() {
        view.addSubview(backButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        
        guard let buttonImage = UIImage(named: "nav_back_button") else { return }
        backButton.setImage(buttonImage, for: .normal)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 23)
        ])
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            authDelegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}
