//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Aleksandr Eliseev on 09.03.2023.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // app variable
    
    // MARK: Login details
    private let login: String = ""
    private let loginPassword: String = ""
    private let userProfileName: String = ""
    private let userProfilelogin: String = ""
    
    // MARK: Lifecycle

    override func setUpWithError() throws {
        
        continueAfterFailure = false
        app.launch() // start app before each test

    }
    
    // MARK: Login test
    
    func testAuth() throws {
        // test auth scenario
        
        /// Нажать кнопку авторизации
        
        /*
         У приложения мы получаем список кнопок на экране и получаем нужную кнопку по тексту на ней
         Далее вызываем функцию tap() для нажатия на этот элемент
         */
        let authorize = app.buttons["Authenticate"]
        authorize.tap()
        /// Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"] // вернёт нужный WebView
        XCTAssertTrue(webView.waitForExistence(timeout: 5)) // подождёт 5 секунд, пока WebView не появится
        
        let loginTextField = webView.descendants(matching: .textField).element // найдёт поле для ввода пароля
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        /// Ввести данные в форму
        loginTextField.tap()
        loginTextField.typeText("\(login)")
        webView.swipeUp() // поможет скрыть клавиатуру после ввода текста

        sleep(2)
        
        
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element // найдёт поле для ввода пароля
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        /// Ввести данные в форму
        passwordTextField.tap()
        passwordTextField.typeText("\(loginPassword)")
        
        sleep(2)
        webView.swipeUp()
        
        print(app.debugDescription) // дерево UI-элементов для отладки и выявления проблем
        
        /// Нажать кнопку логина
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }
    
    // MARK: Like and singleIMage test
    
    func testFeed() throws {
        // test feed scenario
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp() // Сделать жест «смахивания» вверх по экрану для его скролла
        // Подождать, пока открывается и загружается экран ленты
        XCTAssertTrue(cell.waitForExistence(timeout: 2))
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        // Поставить лайк в ячейке верхней картинки
        cellToLike.buttons["likeButton"].tap()
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["likeButton"].tap()
        
        sleep(2)
        
        // Нажать на верхнюю ячейку
        cellToLike.tap()
        
        // Подождать, пока картинка открывается на весь экран
        sleep(2)
        
        let image = app.scrollViews.element(boundBy: 0)
        // Увеличить картинку
        image.pinch(withScale: 1.25, velocity: 1)
        // Уменьшить картинку
        image.pinch(withScale: 0.1, velocity: -1)
        // Вернуться на экран ленты
        let navBackButton = app.buttons["dismissButton"]
        navBackButton.tap()
    }
    
    // MARK: Logout test
    
    func testProfile() throws {
        // test profile scenario
        
        // Подождать, пока открывается и загружается экран ленты
        sleep(3)
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["\(userProfileName)"].exists)
        XCTAssertTrue(app.staticTexts["@\(userProfilelogin)"].exists)
        // Нажать кнопку логаута
        app.buttons["logoutButton"].tap()
        
        let alert = app.alerts["Alert"]
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Пока-пока!")
        
        app.alerts["Alert"].scrollViews.otherElements.buttons["Да"].tap()
        // Проверить, что открылся экран авторизации
        sleep(3)

        XCTAssertFalse(alert.exists)
        XCTAssertTrue(app.buttons["Authenticate"].exists)
    }

    
}
