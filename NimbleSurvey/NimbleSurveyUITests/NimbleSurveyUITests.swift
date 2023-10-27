//
//  NimbleSurveyUITests.swift
//  NimbleSurveyUITests
//
//  Created by Tanatip Denduangchai on 10/23/23.
//

import XCTest

final class NimbleSurveyUITests: XCTestCase {

    override class func setUp() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }
}
