//
//  TokenRefreshUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest
@testable import NimbleSurvey

class TokenRefresherTests: XCTestCase {

    class MockTokenRefresher: TokenRefresher {
        var onErrorCalled = false
        var onSuccessCalled = false
        var onFailureCalled = false
        var didEnterBackgroundCalled = false
        var willEnterForegroundCalled = false

        override func appDidEnterBackground() {
            self.didEnterBackgroundCalled = true
        }

        override func appWillEnterForeground() {
            self.willEnterForegroundCalled = true
        }

        override func onErrorUnitTesting() {
            self.onErrorCalled = true
            super.onError()
        }

        override func onSuccess(data: String) {
            self.onSuccessCalled = true
            super.onSuccess(data: data)
        }

        override func onFailure() {
            self.onFailureCalled = true
            super.onFailure()
        }
    }

    class ObservableTimer: Timer {
        var invalidateCalled = false

        override func invalidate() {
            self.invalidateCalled = true
        }
    }

    var tokenRefresher: TokenRefresher!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        self.mockSession = MockURLSession()
        NetworkManager.shared.setSession(self.mockSession)
        self.tokenRefresher = TokenRefresher()
    }

    override func tearDown() {
        self.tokenRefresher = nil
        NetworkManager.shared.setSession(URLSession(configuration: .default))
        self.mockSession = nil
        super.tearDown()
    }

    func testRefreshToken_NoData() {
        // Given
        let jsonData = """
            {
                "data": {
                    "id": "10",
                        "type": "token",
                        "attributes": {
                            "token_type": "Bearer",
                                "expires_in": 7200,
                                "created_at": 1597169495
                        }
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

        let mockRefresher = MockTokenRefresher()
        NetworkManager.shared.setSession(self.mockSession)

        let expectation = self.expectation(description: "200 status with no refreshToken should call onError")

        // When
        mockRefresher.refreshToken()

        // Then
        DispatchQueue.main.async {
            XCTAssertTrue(mockRefresher.onErrorCalled, "Expected onError() to be called, but it wasn't.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRefreshToken_EmptyRefreshToken() {
        // Given
        let jsonData = Data("""
                            {
                                "data": {
                                    "id": "10",
                                    "type": "token",
                                    "attributes": {
                                        "access_token": "",
                                        "token_type": "Bearer",
                                        "expires_in": 7200,
                                        "refresh_token": "",
                                        "created_at": 1597169495
                                    }
                                }
                            }
            """.utf8)

        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil

        let mockRefresher = MockTokenRefresher()
        NetworkManager.shared.setSession(self.mockSession)

        let expectation = self.expectation(description: "Empty refreshToken should call onError")

        // When
        mockRefresher.refreshToken()

        // Then
        DispatchQueue.main.async {
            XCTAssertTrue(mockRefresher.onErrorCalled, "Expected onError() to be called, but it wasn't.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRefreshToken_OnSuccess() {
        // Given
        let jsonData = """
            {
                "data": {
                    "id": "10",
                    "type": "token",
                    "attributes": {
                        "access_token": "lbxD2K2BjbYtNzz8xjvh2FvSKx838KBCf79q773kq2c",
                        "token_type": "Bearer",
                        "expires_in": 7200,
                        "refresh_token": "3zJz2oW0njxlj_I3ghyUBF7ZfdQKYXd2n0ODlMkAjHc",
                        "created_at": 1597169495
                    }
                }
            }
            """.data(using: .utf8)!
        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil

        let mockRefresher = MockTokenRefresher()
        NetworkManager.shared.setSession(self.mockSession)

        let expectation = self.expectation(description: "Valid refreshToken should call onSuccess")

        // When
        mockRefresher.refreshToken()

        // Then
        DispatchQueue.main.async {
            XCTAssertTrue(mockRefresher.onSuccessCalled, "Expected onSuccess() to be called, but it wasn't.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRefreshToken_OnFailure() {
        // Given
        let jsonData = """
            {
                "errors": [
                    {
                        "source": "Doorkeeper::OAuth::Error",
                        "detail": "The provided authorization grant is invalid, expired, revoked, does not match the redirection URI used in the authorization request, or was issued to another client.",
                        "code": "invalid_grant"
                    }
                ]
            }
            """.data(using: .utf8)!
        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 400,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil

        let mockRefresher = MockTokenRefresher()
        NetworkManager.shared.setSession(self.mockSession)

        let expectation = self.expectation(description: "Error response should call onFailure")

        // When
        mockRefresher.refreshToken()

        // Then
        DispatchQueue.main.async {
            XCTAssertTrue(mockRefresher.onFailureCalled, "Expected onFailure() to be called, but it wasn't.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testRefreshToken_StartTimer() {
        let tokenRefresher = TokenRefresher()

        tokenRefresher.startTimer()

        XCTAssertNotNil(tokenRefresher.refreshTokenTimer, "Expected timer to be started")
    }

    func testRefreshToken_StopTimer() {
        let tokenRefresher = TokenRefresher()
        let observableTimer = ObservableTimer()

        tokenRefresher.refreshTokenTimer = observableTimer
        tokenRefresher.stopTimer()

        XCTAssertTrue(observableTimer.invalidateCalled, "Expected timer to be invalidated")
        XCTAssertNil(tokenRefresher.refreshTokenTimer, "Expected timer to be nil")
    }

    func testRefreshToken_SaveRefreshToken() {
        let testToken = "TestToken"

        // Call the function that triggers saving the token
        _ = Keychain.shared.saveRefreshToken(data: testToken)

        // Retrieve the token from Keychain and verify
        let savedToken = Keychain.shared.getRefreshToken()
        XCTAssertEqual(savedToken, testToken, "Expected token to be saved")
    }

    func testRefreshToken_NotificationPosted() {
        let expectation = self.expectation(description: "Notification should be posted")

        // Observe the notification
        let observer = NotificationCenter.default.addObserver(
            forName: .refresherTokenOnSuccessAutoLogin,
            object: nil,
            queue: nil)
        { _ in
            expectation.fulfill()
        }

        // Trigger the notification posting
        NotificationCenter.default.post(name: .refresherTokenOnSuccessAutoLogin, object: nil)

        // Wait for expectations
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func testRefreshToken_RemoveRefreshToken() {
        // Initially save a token
        let testToken = "TestToken"
        _ = Keychain.shared.saveRefreshToken(data: testToken)

        // Call the function that triggers removing the token
        _ = Keychain.shared.removeRefreshToken()

        // Retrieve the token from Keychain and verify it is removed
        let savedToken = Keychain.shared.getRefreshToken()
        XCTAssertEqual(savedToken, "", "Expected token to be an empty string")
    }

    func testRefreshToken_FailureNotificationPosted() {
        let expectation1 = self.expectation(description: "Notification .refresherTokenOnFailureAutoLogin should be posted")
        let expectation2 = self.expectation(description: "Notification .refresherTokenOnFailure should be posted")

        // Observe the notifications
        let observer1 = NotificationCenter.default.addObserver(
            forName: .refresherTokenOnFailureAutoLogin,
            object: nil,
            queue: nil)
        { _ in
            expectation1.fulfill()
        }

        let observer2 = NotificationCenter.default
            .addObserver(forName: .refresherTokenOnFailure, object: nil, queue: nil) { _ in
                expectation2.fulfill()
            }

        // Trigger the notification posting
        NotificationCenter.default.post(name: .refresherTokenOnFailureAutoLogin, object: nil)
        NotificationCenter.default.post(name: .refresherTokenOnFailure, object: nil)

        // Wait for expectations
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
            NotificationCenter.default.removeObserver(observer1)
            NotificationCenter.default.removeObserver(observer2)
        }
    }

    func testRefreshToken_DidEnterBackground() {
        // Given
        let mockRefresher = MockTokenRefresher()

        // When
        NotificationCenter.default.post(name: .refresherTokenAppDidEnterBackground, object: nil)

        // Then
        XCTAssertTrue(mockRefresher.didEnterBackgroundCalled, "Expected appDidEnterBackground() to be called")
    }

    func testRefreshToken_WillEnterForeground() {
        // Given
        let mockRefresher = MockTokenRefresher()

        // When
        NotificationCenter.default.post(name: .refresherTokenAppWillEnterForeground, object: nil)

        // Then
        XCTAssertTrue(mockRefresher.willEnterForegroundCalled, "Expected appWillEnterForeground() to be called")
    }
}
