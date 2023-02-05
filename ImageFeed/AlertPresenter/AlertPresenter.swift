//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 05.02.2023.
//

import UIKit

struct AlertPresenter: AlertPresenterProtocol {
    
    private weak var alertDelegate: AlertPresenterDelegate?
    
    init(alertDelegate: AlertPresenterDelegate) {
        self.alertDelegate = alertDelegate
    }
    
    func makeAlertController(alert: AlertModel) {
        let customAlert = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        
        customAlert.view.accessibilityIdentifier = "NetworkErrorAlert"
        
        let action = UIAlertAction(
            title: alert.buttonText,
            style: .cancel,
            handler: alert.completion)
        
        customAlert.addAction(action)
        
        alertDelegate?.showAlert(alert: customAlert)
    }
    
    
}
