//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 29.12.2022.
//

import UIKit

class ProfileViewController: UIViewController {

    private var profileImage = UIImageView()
    private var logoutButton = UIButton()
    private var userNameLabel = UILabel()
    private var userEmailLabel = UILabel()
    private var userDescriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupUI() {
        
        view.backgroundColor = .ypBlack
        
        setupProfileImage()
        setupLogoutButton()
        setupUserNameLabel()
        setupUserEmail()
        setupUserDescription()
        
    }
    
    private func setupProfileImage() {
        view.addSubview(profileImage)
        profileImage.translatesAutoresizingMaskIntoConstraints = false
        
        profileImage.image = UIImage(named: "person.crop.circle.fill")
        
        NSLayoutConstraint.activate([
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.heightAnchor.constraint(equalToConstant: 70),
            profileImage.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupLogoutButton() {
        view.addSubview(logoutButton)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        logoutButton.setImage(UIImage(named: "ipad.and.arrow.forward"), for: .normal)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
        ])
    }
    
    private func setupUserNameLabel() {
        view.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userNameLabel.font = .systemFont(ofSize: 23, weight: .bold)
        userNameLabel.textColor = .ypWhite
        userNameLabel.text = "Екатерина Новикова"
        
        NSLayoutConstraint.activate([
            userNameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -124),
        ])
    }
    
    private func setupUserEmail() {
        view.addSubview(userEmailLabel)
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userEmailLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userEmailLabel.textColor = .ypGrey
        userEmailLabel.text = "@ekaterina.nov"
        
        NSLayoutConstraint.activate([
            userEmailLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            userEmailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userEmailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -260),
        ])
    }
    
    private func setupUserDescription() {
        view.addSubview(userDescriptionLabel)
        userDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        userDescriptionLabel.font = .systemFont(ofSize: 13, weight: .regular)
        userDescriptionLabel.textColor = .ypWhite
        userDescriptionLabel.text = "Hello, world!"
        
        NSLayoutConstraint.activate([
            userDescriptionLabel.topAnchor.constraint(equalTo: userEmailLabel.bottomAnchor, constant: 8),
            userDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            userDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -282),
        ])
    }
}
