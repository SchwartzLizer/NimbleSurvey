//
//  NimbleSurveyUITests.swift
//  NimbleSurveyUITests
//
//  Created by Tanatip Denduangchai on 10/23/23.
//

import XCTest

final class NimbleSurveyUITests: XCTestCase {

    override func setUpWithError() throws {
        let app = XCUIApplication()
        setupSnapshot(app) // Fastlane Snapshot
        app.launch()

        continueAfterFailure = false
    }

    func testForgotPasswordScreenshots() throws {
        let app = XCUIApplication()
        // MARK: Login
        snapshot("LoginScreen")
        print("Take screenshot LoginScreen")
        print("LoginScreen Done")

        // MARK: ForgotPassword
        XCUIApplication().staticTexts["Forgot?"].tap()
        snapshot("ForgotPasswordScreen")
        print("Take screenshot ForgotPasswordScreen")
        sleep(1)
        app.textFields["Email"].tap()
        app.staticTexts["Reset"].tap()
        snapshot("ForgotPasswordScreen - Empty")
        print("Take screenshot ForgotPasswordScreen - Empty")
        app.alerts["Nimble Survey"].scrollViews.otherElements.buttons["OK"].tap()
        let emailForgotPasswordTextfield = app.textFields[Constants.AccessibilityID.emailForgetPasswordTextField]
        XCTAssertTrue(emailForgotPasswordTextfield.exists, "The expected text field does not exist.")
        emailForgotPasswordTextfield.tap()
        emailForgotPasswordTextfield.typeText("dev@nimblehq.co")
        app.buttons["Reset"].tap()
        sleep(1)
        snapshot("ForgotPasswordScreen - Success")
        print("Take screenshot ForgotPasswordScreen - Success")
        emailForgotPasswordTextfield.tap()
        emailForgotPasswordTextfield.typeText("")
        app.buttons["Reset"].tap()
        snapshot("ForgotPasswordScreen - Failed")
        print("Take screenshot ForgotPasswordScreen - Failed")
        app.alerts["Nimble Survey"].scrollViews.otherElements.buttons["OK"].tap()
        XCUIApplication().navigationBars["NimbleSurvey.ForgotPasswordView"].buttons["Back"].tap()
        print("ForgotPasswordScreen Done")
        sleep(1)

        // MARK: Login
        let emailLoginTextfield = app.textFields[Constants.AccessibilityID.emailLoginTextField]
        XCTAssertTrue(emailLoginTextfield.exists, "The expected text field does not exist.")
        let passwordLoginTextfield = app.secureTextFields[Constants.AccessibilityID.passwordLoginTextField]
        XCTAssertTrue(passwordLoginTextfield.exists, "The expected text field does not exist.")
        emailLoginTextfield.tap()
        emailLoginTextfield.typeText("ABC@Email.com")
        passwordLoginTextfield.tap()
        passwordLoginTextfield.typeText("12345678")
        app.buttons["Log in"].tap()
        sleep(1)
        snapshot("LoginScreen - Failed")
        print("Take screenshot LoginScreen - Failed")
        app.alerts["Nimble Survey"].scrollViews.otherElements.buttons["OK"].tap()
        emailLoginTextfield.tap()
        emailLoginTextfield.typeText("dev@nimblehq.co")
        passwordLoginTextfield.tap()
        passwordLoginTextfield.typeText("12345678")
        app.buttons["Log in"].tap()
        snapshot("LoginScreen - Success")
        print("LoginScreen Done")
        sleep(5)

        // MARK: Home
        snapshot("HomeScreen")
        print("Take screenshot HomeScreen")
        sleep(1)
        let element = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element
        let ProfileHomeButton = element.children(matching: .other).element.children(matching: .other).element
            .children(matching: .other).element.children(matching: .other).element.children(matching: .other).element
            .children(matching: .other).element(boundBy: 0).children(matching: .other).element(boundBy: 1)
            .children(matching: .other).element(boundBy: 1).children(matching: .button).element

        ProfileHomeButton.tap()
        snapshot("HomeScreen - Right Menu")
        print("Take screenshot HomeScreen - Right Menu")
        app.collectionViews/*@START_MENU_TOKEN@*/.images/*[[".cells.images",".images"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.children(matching: .other).element.tap()
        sleep(1)

        // MARK: Survey
        app.buttons["Action"].tap()
        snapshot("HomeScreen - Survey Welcome")
        print("Take screenshot HomeScreen - Survey Welcome")
        app.collectionViews.buttons["Back"].tap()
        print("Done")
    }

}
