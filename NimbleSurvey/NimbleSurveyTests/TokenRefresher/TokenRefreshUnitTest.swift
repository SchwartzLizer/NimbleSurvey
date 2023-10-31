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
    }

    override func tearDown() {
        self.tokenRefresher.stopTimer()
        self.tokenRefresher = nil
        super.tearDown()
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


}

