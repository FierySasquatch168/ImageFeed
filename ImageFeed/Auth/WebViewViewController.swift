//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 19.01.2023.
//

import UIKit
import WebKit

protocol WebViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

final class WebViewViewController: UIViewController & WebViewControllerProtocol {
    private var estimatedProgressObservation: NSKeyValueObservation?
    
    weak var authDelegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    
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
        setupProgressView()
        presenter?.viewDidLoad()
        setupKVObserver()
        
    }
    // MARK: Observer setup
    
    private func setupKVObserver() {
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
             })
    }
    
    // MARK: Protocol methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    // MARK: Class methods
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        
        return nil
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

// MARK: Extension WKNAvigationDelegate

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
