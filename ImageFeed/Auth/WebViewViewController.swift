//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 19.01.2023.
//

import UIKit
import WebKit

final class WebViewViewController: UIViewController {

    private let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    weak var authDelegate: WebViewViewControllerDelegate?
    
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
        
    }
    // MARK: Observer setup
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        /// In case of inherited classes presence the context must not be nil, if the parent class is final - nil for context is ok
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        
        updateProgress()
    }
    
    // MARK: Observer removal
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        webView.removeObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            context: nil)
    }
    
    // MARK: Observer
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?)
    {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
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
        var urlComponents = URLComponents(string: UnsplashAuthorizeURLString)
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
