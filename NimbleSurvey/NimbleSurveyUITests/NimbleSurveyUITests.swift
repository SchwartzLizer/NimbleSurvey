//
//  NimbleSurveyUITests.swift
//  NimbleSurveyUITests
//
//  Created by Tanatip Denduangchai on 10/23/23.
//

import XCTest

final class NimbleSurveyUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let app = XCUIApplication()
        setupSnapshot(app) // Set up snapshot here if you haven't already
        app.launch()

        continueAfterFailure = false
    }

    func takeLoginScreenShots() throws {
        let app = XCUIApplication()
        snapshot("LoginScreen")
        print("Take screenshot LoginScreen")
        print("LoginScreen Done")
    }

    func testForgotPasswordScreenshots() throws {
        let app = XCUIApplication()
        XCUIApplication().staticTexts["Forgot?"].tap()
        snapshot("ForgotPasswordScreen")
        print("Take screenshot ForgotPasswordScreen")
        sleep(1)

        app.textFields["Email"].tap()
        app.staticTexts["Reset"].tap()
        snapshot("ForgotPasswordScreen - Empty")
        print("Take screenshot ForgotPasswordScreen - Empty")

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

        XCUIApplication().navigationBars["NimbleSurvey.ForgotPasswordView"].buttons["Back"].tap()
        print("ForgotPasswordScreen Done")
        sleep(1)
    }

    func testLoginStateScreenShot() throws {
        let app = XCUIApplication()
        let emailLoginTextfield = app.textFields[Constants.AccessibilityID.emailLoginTextField]
        XCTAssertTrue(emailLoginTextfield.exists, "The expected text field does not exist.")
        let passwordLoginTextfield = app.secureTextFields[Constants.AccessibilityID.passwordLoginTextField]
        XCTAssertTrue(passwordLoginTextfield.exists, "The expected text field does not exist.")

        emailLoginTextfield.tap()
        emailLoginTextfield.typeText("ABC@Email.com")
        passwordLoginTextfield.tap()
        passwordLoginTextfield.typeText("12345678")
        app.buttons["Login"].tap()

        sleep(1)
        snapshot("LoginScreen - Failed")
        print("Take screenshot LoginScreen - Failed")

        emailLoginTextfield.tap()
        emailLoginTextfield.typeText("dev@nimblehq.co")
        passwordLoginTextfield.tap()
        passwordLoginTextfield.typeText("12345678")
        app.buttons["Login"].tap()
        print("LoginScreen Done")
        sleep(1)
    }

}
