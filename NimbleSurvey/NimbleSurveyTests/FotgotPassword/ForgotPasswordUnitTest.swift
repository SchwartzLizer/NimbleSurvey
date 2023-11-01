//
//  ForgotPasswordUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class ForgotPasswordUnitTest: XCTestCase {

    var viewModel: ForgotPasswordViewModel!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        self.mockSession = MockURLSession()
        NetworkManager.shared.setSession(self.mockSession)
        self.viewModel = ForgotPasswordViewModel()
    }

    override func tearDown() {
        self.viewModel = ForgotPasswordViewModel()
        NetworkManager.shared.setSession(URLSession(configuration: .default))
        self.mockSession = nil
        super.tearDown()
    }

    func testForgotPasswordUnitTest_Success() {
        let jsonData = """
            {
                "meta": {
                    "message": "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
                }
            }
            """.data(using: .utf8)
        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil
        let expectation = XCTestExpectation(description: "Reset password success")
        self.viewModel.requestForgotPassword(email: "test@example.com")
        self.viewModel.resetSuccess = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testForgotPasswordUnitTest_Failure() {
        let errorJsonData = """
            {
                "errors": [
                    {
                        "detail": "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.",
                        "code": "invalid_client"
                    }
                ]
            }
            """.data(using: .utf8)
        self.mockSession.data = errorJsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil
        let expectation = XCTestExpectation(description: "Reset password failure")
        var resetFailedCalled = false
        self.viewModel.resetFailed = { _ in
            resetFailedCalled = true
            expectation.fulfill()
        }
        self.viewModel.requestForgotPassword(email: "invalid-email")
        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(resetFailedCalled, "resetFailed should have been called")
    }

}

