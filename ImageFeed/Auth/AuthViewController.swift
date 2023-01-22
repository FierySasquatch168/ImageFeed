//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 19.01.2023.
//

import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController  {
    
    private weak var oAuth2Service: OAuth2Service?
    private weak var oAuth2TokenStorage: OAuth2TokenStorage?
    weak var authViewControllerDelegate: AuthViewControllerDelegate?

    private lazy var mainImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Vector 1")
        
        return imageView
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.layer.backgroundColor = UIColor.ypWhite?.cgColor
        
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        button.setTitleColor(.ypBlack, for: .normal)
        button.setTitle("Войти", for: .normal)
        
        button.addTarget(self, action: #selector(goToWebVC), for: .touchUpInside)
        
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBlack
        
        setupMainImage()
        setuploginButton()
        
        if oAuth2TokenStorage != nil {
            print("oAuth2TokenStorage is not nil")
        } else {
            print("oAuth2TokenStorage is nil")
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: WebViewViewControllerDelegate methods

    
    @objc private func goToWebVC() {
        let nextViewController = WebViewViewController()
        nextViewController.modalPresentationStyle = .fullScreen
        nextViewController.authDelegate = self
        
        self.present(nextViewController, animated: true)
    }
    
    // MARK: UI setup
    
    private func setupMainImage() {
        view.addSubview(mainImage)
        mainImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            mainImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            mainImage.heightAnchor.constraint(equalToConstant: 60),
            mainImage.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setuploginButton() {
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -111),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        oAuth2Service?.fetchAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            print("AuthViewController oAuth2Service?.fetchAuthToken works")
            switch result {
            case .success(let token):
                self.oAuth2TokenStorage?.token = token
                print(token)
            case .failure(let error):
                print(error) // TODO: to add alert for error case
            }
        })
        
        authViewControllerDelegate?.authViewController(self, didAuthenticateWithCode: code)
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
        print("AuthVC webViewViewControllerDidCancel works")
    }
}
