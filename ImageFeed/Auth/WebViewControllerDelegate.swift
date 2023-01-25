//
//  WebViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Aleksandr Eliseev on 20.01.2023.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
