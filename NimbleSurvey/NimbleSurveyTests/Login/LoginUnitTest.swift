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
        self.viewModel = LoginViewModel()
        NetworkManager.shared.setSession(URLSession(configuration: .default))
        self.mockSession = nil
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


}

