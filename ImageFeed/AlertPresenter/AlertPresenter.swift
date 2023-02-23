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
    
    func presentAlertController(alert: AlertModel) {
        let customAlert = UIAlertController(
            title: alert.title,
            message: alert.message,
            preferredStyle: .alert)
        
        customAlert.view.accessibilityIdentifier = "Alert"
        
        let action = UIAlertAction(
            title: alert.buttonText,
            style: .cancel,
            handler: alert.leftCompletion)
        
        customAlert.addAction(action)
        
        if let actionText = alert.actionText {
            let secondAction = UIAlertAction(
                title: actionText,
                style: .default,
                handler: alert.rightCompletion)
            
            customAlert.addAction(secondAction)
        }
        
        alertDelegate?.showAlert(alert: customAlert)
    }
    
    
    
    
}
