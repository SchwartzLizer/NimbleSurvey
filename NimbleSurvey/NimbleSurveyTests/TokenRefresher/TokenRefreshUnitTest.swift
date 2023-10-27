//
//  TokenRefreshUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest
@testable import NimbleSurvey

class TokenRefresherTests: XCTestCase {

    var tokenRefresher: TokenRefresher!

    override func setUp() {
        super.setUp()
        self.tokenRefresher = TokenRefresher.shared
        self.prepareRefreshToken()
    }

    override func tearDown() {
        self.tokenRefresher.stopTimer()
        self.tokenRefresher = nil
        super.tearDown()
    }

    // MARK: Initalize
    func prepareRefreshToken() {
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
                guard let refreshToken = value.data?.attributes?.refreshToken
                else { return XCTFail("Error, no token in response") }
                UserDefault().saveRefreshToken(data: refreshToken)
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

    func testStartTimer() {
        self.tokenRefresher.startTimer()
        XCTAssertNotNil(self.tokenRefresher.refreshTokenTimer, "Timer should be set")
    }

    func testStopTimer() {
        self.tokenRefresher.startTimer()
        self.tokenRefresher.stopTimer()
        XCTAssertNil(self.tokenRefresher.refreshTokenTimer, "Timer should be nil after stopping")
    }

    func testRefreshTokenSuccess() {
        let expectation = self.expectation(description: "Token should be refreshed")
        self.tokenRefresher.onSuccess = {
            expectation.fulfill()
        }
        self.tokenRefresher.refreshToken()
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testRefreshTokenFailure() {
        let expectation = self.expectation(description: "Token refresh should fail")
        self.tokenRefresher.onFailed = {
            expectation.fulfill()
        }
        UserDefault().saveRefreshToken(data: "")
        self.tokenRefresher.refreshToken()
        waitForExpectations(timeout: 1.0, handler: nil)
    }

}

