//
//  RightMenuUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class RightMenuUnitTest: XCTestCase {

    var viewModel: RightMenuViewModel!
    var token: String?

    override func setUp() {
        super.setUp()
        self.viewModel = RightMenuViewModel(model: RightMenuModel(name: "", profileImage: ""))
        self.prepareRefreshToken()
    }

    override func tearDown() {
        self.viewModel = nil
        super.tearDown()
    }

    // MARK: Initalize
    func prepareRefreshToken() {
        let expectation = self.expectation(description: "Prepare login stage")
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
                guard let refreshToken = value.data?.attributes?.refreshToken
                else { return XCTFail("Error, no token in response") }
                self.token = refreshToken
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

    // MARK: 403 - unauthorized_client
    func testLogoutFailure() {
        let expectation = self.expectation(description: "Logout should failed")
        guard let token = self.token else {
            XCTFail("Token not found")
            return
        }
        let clientID = ""
        let clientSecret = ""

        let router = Router.logout(token: token, clientID: clientID, clientSecret: clientSecret)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LogoutModel, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for 'Logout should failed' but got success.")
                expectation.fulfill()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    XCTAssertFalse(errorResponse.errors.isEmpty, "Expected non-empty errors list")
                    let detail = errorResponse.errors.first?.detail ?? ""
                    Logger.print(detail)
                    XCTAssertEqual(
                        detail,
                        "You are not authorized to revoke this token")
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
        let expectation = self.expectation(description: "Logout should success")
        guard let token = self.token else {
            XCTFail("Token not found")
            return
        }
        let clientID = Constants.ServiceKeys.key
        let clientSecret = Constants.ServiceKeys.secrect

        let router = Router.logout(token: token, clientID: clientID, clientSecret: clientSecret)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LogoutModel, NetworkError>) in
            switch result {
            case .success(let value):
                Logger.print("Data \(value)")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Logout failed with error: \(error)")
            }
        }

        self.waitForExpectations(timeout: 10.0) { error in
            if let error = error {
                XCTFail("Expectation failed with error: \(error)")
            }
        }
    }

}
