//
//  LoginUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest
@testable import NimbleSurvey

final class LoginUnitTest: XCTestCase {

    var viewModel: LoginViewModel!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        self.mockSession = MockURLSession()
        NetworkManager.shared.setSession(self.mockSession)
        self.viewModel = LoginViewModel()
    }

    override func tearDown() {
        self.viewModel = nil
        self.mockSession = nil
        NetworkManager.shared.setSession(URLSession(configuration: .default))
        super.tearDown()
    }

    func testLogin_Success() {
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
        let expectation = XCTestExpectation(description: "Login success")
        self.viewModel.requestLogin(email: "test@example.com", password: "password")
        self.viewModel.loginSuccess = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLogin_Failure() {
        let jsonData = """
                {
                    "errors": [
                        {
                            "detail": "Your email or password is incorrect. Please try again.",
                            "code": "invalid_email_or_password"
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
        let expectation = XCTestExpectation(description: "Login failure")
        self.viewModel.requestLogin(email: "invalid-email", password: "invalid-password")
        self.viewModel.loginFailure = { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLogin_RefreshTokenNotFound() {
        let jsonData = """
                {
                    "data": {
                        "id": "10",
                        "type": "token",
                        "attributes": {
                            "access_token": "lbxD2K2BjbYtNzz8xjvh2FvSKx838KBCf79q773kq2c",
                            "token_type": "Bearer",
                            "expires_in": 7200,
                            "refresh_token": "",
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
        let expectation = XCTestExpectation(description: "No refresh token found")
        self.viewModel.requestLogin(email: "test@example.com", password: "password")
        self.viewModel.noRefreshTokenFound = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLogin_RefreshTokenIsEmpty() {
        let jsonData = """
                {
                    "data": {
                        "id": "10",
                        "type": "token",
                        "attributes": {
                            "access_token": "lbxD2K2BjbYtNzz8xjvh2FvSKx838KBCf79q773kq2c",
                            "token_type": "Bearer",
                            "expires_in": 7200,
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
        let expectation = XCTestExpectation(description: "No refresh token found")
        self.viewModel.requestLogin(email: "test@example.com", password: "password")
        self.viewModel.noRefreshTokenFound = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLogin_AccessTokenNotFound() {
        let jsonData = """
                {
                    "data": {
                        "id": "10",
                        "type": "token",
                        "attributes": {
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
        let expectation = XCTestExpectation(description: "No access token found")
        self.viewModel.requestLogin(email: "test@example.com", password: "password")
        self.viewModel.noAccessTokenFound = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testLogin_AccessTokenisEmpty() {
        let jsonData = """
                {
                    "data": {
                        "id": "10",
                        "type": "token",
                        "attributes": {
                            "access_token": "",
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
        let expectation = XCTestExpectation(description: "No access token found")
        self.viewModel.requestLogin(email: "test@example.com", password: "password")
        self.viewModel.noAccessTokenFound = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    // Tests for handleRefreshToken

    func testLogin_handleRefreshToken_Save() {
        let attributes = LoginAttributes(
            accessToken: "",
            tokenType: nil,
            expiresIn: nil,
            refreshToken: "testToken",
            createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)
        self.viewModel.handleRefreshToken(model: model)
        let fetchedToken = Keychain.shared.getRefreshToken()
        XCTAssertEqual(fetchedToken, "testToken")
    }

    func testLogin_HandleRefreshToken_withNilToken() {
        let attributes = LoginAttributes(accessToken: nil, tokenType: nil, expiresIn: nil, refreshToken: nil, createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)
        var noRefreshTokenFoundCalled = false
        self.viewModel.noRefreshTokenFound = { noRefreshTokenFoundCalled = true }
        self.viewModel.handleRefreshToken(model: model)
        XCTAssertTrue(noRefreshTokenFoundCalled, "noRefreshTokenFound closure was not invoked")
    }

    func testLogin_HandleRefreshToken_withEmptyToken() {
        let attributes = LoginAttributes(accessToken: "", tokenType: nil, expiresIn: nil, refreshToken: "", createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)
        var noRefreshTokenFoundCalled = false
        self.viewModel.noRefreshTokenFound = { noRefreshTokenFoundCalled = true }
        self.viewModel.handleRefreshToken(model: model)
        XCTAssertTrue(noRefreshTokenFoundCalled, "noRefreshTokenFound closure was not invoked")
    }

    func testLogin_HandleAccessToken_withValidToken() {
        let testToken = "testToken"
        let attributes = LoginAttributes(
            accessToken: testToken,
            tokenType: nil,
            expiresIn: nil,
            refreshToken: nil,
            createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)

        var loginSuccessCalled = false
        self.viewModel.loginSuccess = { loginSuccessCalled = true }

        self.viewModel.handleAccessToken(model: model)

        let fetchedToken = Keychain().getAccessToken()
        XCTAssertEqual(fetchedToken, testToken, "Saved token does not match expected token")
        XCTAssertNotNil(TokenRefresher.shared.refreshTokenTimer, "Expected timer to be started")
        XCTAssertTrue(loginSuccessCalled, "loginSuccess closure was not invoked")
    }

    func testLogin_HandleAccessToken_withEmptyToken() {
        let attributes = LoginAttributes(accessToken: "", tokenType: nil, expiresIn: nil, refreshToken: nil, createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)

        var noAccessTokenFoundCalled = false
        self.viewModel.noAccessTokenFound = { noAccessTokenFoundCalled = true }

        self.viewModel.handleAccessToken(model: model)

        XCTAssertTrue(noAccessTokenFoundCalled, "noAccessTokenFound closure was not invoked")
    }

    func testLogin_HandleAccessToken_withNilToken() {
        let attributes = LoginAttributes(accessToken: nil, tokenType: nil, expiresIn: nil, refreshToken: nil, createdAt: nil)
        let data = LoginData(id: "1", type: "login", attributes: attributes)
        let model = LoginModel(data: data)

        var noAccessTokenFoundCalled = false
        self.viewModel.noAccessTokenFound = { noAccessTokenFoundCalled = true }

        self.viewModel.handleAccessToken(model: model)

        XCTAssertTrue(noAccessTokenFoundCalled, "noAccessTokenFound closure was not invoked")
    }

}

