//
//  ForgotPasswordUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class ForgotPasswordUnitTest: XCTestCase {

    var viewModel: ForgotPasswordViewModel!

    override func setUp() {
        super.setUp()
        self.viewModel = ForgotPasswordViewModel()
    }

    override func tearDown() {
        self.viewModel = nil
        super.tearDown()
    }

    // MARK: 403 - invalid client
    func testSignInInvaildClient() {
        let expectation = self.expectation(description: "Test Forgot Passwrod invalid client")
        let email = "dev@nimblehq.co"
        let clientID = ""
        let clientSecret = ""

        let router = Router.forgotPassword(email: email, clientID: clientID, clientSecret: clientSecret)


        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
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
    func testFogotPasswordSuccess() {
        let expectation = self.expectation(description: "Test Forgot Password success")
        let email = "dev@nimblehq.co"
        let clientID = Constants.ServiceKeys.key
        let clientSecret = Constants.ServiceKeys.secrect

        let router = Router.forgotPassword(email: email, clientID: clientID, clientSecret: clientSecret)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
                case .success(_):
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Forgot Password request failed with error: \(error)")
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }
}

