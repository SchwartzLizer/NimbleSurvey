//
//  NotificationHandlerUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 11/1/23.
//

import XCTest
@testable import NimbleSurvey

class NotificationHandlerTests: XCTestCase {

    class MockNotificationHandlerTestsAppUtility: AppUtilityProtocol {
        var loginSceneCalled = false

        func loginScene() {
            self.loginSceneCalled = true
        }
    }

    class TestableNotificationHandler: NotificationHandler {
        var handleRefreshTokenFailureCalled = false

        override func handleRefreshTokenFailure() {
            self.handleRefreshTokenFailureCalled = true
        }
    }

    var notificationHandler: NotificationHandler!

    override func setUp() {
        super.setUp()
        self.notificationHandler = NotificationHandler()
        self.notificationHandler.alertUtility = MockAlertUtility.self
        self.notificationHandler.appUtility = MockNotificationHandlerTestsAppUtility()
    }

    override func tearDown() {
        self.notificationHandler = nil
        super.tearDown()
    }

    func testNotificationHandler_HandleRefreshTokenFailure() {
        // When
        self.notificationHandler.handleRefreshTokenFailure()

        // Then
        XCTAssertTrue(MockAlertUtility.showAlertCalled, "Expected showAlert to be called")
        XCTAssertEqual(MockAlertUtility.titlePassed, Constants.Keys.appName.localized())
        XCTAssertEqual(MockAlertUtility.messagePassed, Constants.Keys.refresherTokenError.localized())

        // Trigger completion block
        MockAlertUtility.completion?()
        XCTAssertTrue(
            (self.notificationHandler.appUtility as! MockNotificationHandlerTestsAppUtility).loginSceneCalled,
            "Expected loginScene to be called")
    }

    func testNotificationHandler_ObserverSetup() {
        NotificationCenter.default.post(name: .refresherTokenOnFailure, object: nil)
        let expectation = XCTestExpectation(description: "handleRefreshTokenFailure called")
        expectation.fulfill()
        wait(for: [expectation], timeout: 5.0)
    }
}
