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

    override func setUp() {
        super.setUp()
        self.viewModel = LoginViewModel()
    }

    override func tearDown() {
        self.viewModel = nil
        super.tearDown()
    }

    // MARK: 400 - incorrect password
    func testLoginInCorrectEmailOrPassword() {
        let expectation = self.expectation(description: "Test Sign-In incorrect email or password")
        let grantType = "password"
        let email = "dev@nimblehq.co"
        let password = "invalid"
        let clientID = Constants.ServiceKeys.key
        let clientScrect = Constants.ServiceKeys.secrect

        let router = Router.signIn(
            grantType: grantType,
            email: email,
            password: password,
            clientID: clientID,
            clientSecret: clientScrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for 'incorrect email or password' but got success.")
                expectation.fulfill()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    XCTAssertFalse(errorResponse.errors.isEmpty, "Expected non-empty errors list")
                    let detail = errorResponse.errors.first?.detail ?? ""
                    Logger.print(detail)
                    XCTAssertEqual(
                        detail,
                        "Your email or password is incorrect. Please try again.")
                } else {
                    XCTFail("Expected server error with detail, got different error: \(error)")
                }
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }

    // MARK: 400 - invalid grant
    func testLoginInvalidGrant() {
        let expectation = self.expectation(description: "Test Sign-In invalid grant")
        let grantType = "passwordd"
        let email = "dev@nimblehq.co"
        let password = "12345678"
        let clientID = Constants.ServiceKeys.key
        let clientSecret = Constants.ServiceKeys.secrect

        let router = Router.signIn(
            grantType: grantType,
            email: email,
            password: password,
            clientID: clientID,
            clientSecret: clientSecret)

        NetworkManager.shared.request(router: router)
        { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for 'invalid grant' but got success.")
                expectation.fulfill()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    XCTAssertFalse(errorResponse.errors.isEmpty, "Expected non-empty errors list")
                    let detail = errorResponse.errors.first?.detail ?? ""
                    Logger.print(detail)
                    XCTAssertEqual(
                        detail,
                        "The authorization grant type is not supported by the authorization server.")
                } else {
                    XCTFail("Expected server error with detail, got different error: \(error)")
                }
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }

    // MARK: 403 - invalid client
    func testLoginInvaildClient() {
        let expectation = self.expectation(description: "Test Sign-In invalid client")
        let grantType = "password"
        let email = "dev@nimblehq.co"
        let password = "invalid"
        let clientID = "invalid_client_id"
        let clientSecret = "invalid_client_secret"

        let router = Router.signIn(
            grantType: grantType,
            email: email,
            password: password,
            clientID: clientID,
            clientSecret: clientSecret)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for 'invalid client' but got success.")
                expectation.fulfill()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    XCTAssertFalse(errorResponse.errors.isEmpty, "Expected non-empty errors list")
                    let detail = errorResponse.errors.first?.detail ?? ""
                    Logger.print(detail)
                    XCTAssertEqual(
                        detail,
                        "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method.")
                } else {
                    XCTFail("Expected server error with detail, got different error: \(error)")
                }
                expectation.fulfill()
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }

    // MARK: 200 - success
    func testLoginSuccess() {
        let expectation = self.expectation(description: "Test Sign-In success")
        let grantType = "password"
        let email = "dev@nimblehq.co"
        let password = "12345678"
        let clientID = Constants.ServiceKeys.key
        let clientSecret = Constants.ServiceKeys.secrect

        let router = Router.signIn(
            grantType: grantType,
            email: email,
            password: password,
            clientID: clientID,
            clientSecret: clientSecret)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success(let value):
                Logger.print("Data \(value)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Login request failed with error: \(error)")
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }
}

