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

    func testTakeScreenshots() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()

        // Navigate to the screen you want to take a screenshot of
        // ... your UI navigation code goes here ...

        // Take a screenshot with a specific name
        snapshot("01FirstScreen") // The argument is used to name the screenshot

        // Continue with other test operations and screenshots
    }

}
