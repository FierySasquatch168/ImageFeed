//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Aleksandr Eliseev on 08.03.2023.
//

@testable import ImageFeed
import Foundation

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImageFeed.ImagesListPresenterProtocol?
    var didReceivePhotosForTableViewAnumatedUpdateCalled: Bool = false
    var configCellCalled: Bool = false
    
    func didReceivePhotosForTableViewAnimatedUpdate(at indexPaths: [IndexPath]) {
        didReceivePhotosForTableViewAnumatedUpdateCalled = true
    }
    
    func configCell(for cell: ImageFeed.ImagesListCell, with indexPath: IndexPath) {
        configCellCalled = true
    }
    
    
}
