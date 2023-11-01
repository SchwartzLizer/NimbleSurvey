//
//  RightMenuUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class RightMenuUnitTest: XCTestCase {

    var viewModel: RightMenuViewModel!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        self.mockSession = MockURLSession()
        NetworkManager.shared.setSession(self.mockSession)
        self.viewModel = RightMenuViewModel(model: RightMenuModel(name: "", profileImage: ""))
    }

    override func tearDown() {
        self.viewModel = RightMenuViewModel(model: RightMenuModel(name: "", profileImage: ""))
        NetworkManager.shared.setSession(URLSession(configuration: .default))
        self.mockSession = nil
        super.tearDown()
    }

    func testRightMenuLogout_Success() {
        let jsonData = """
            {}
            """.data(using: .utf8)!
        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil
        let expectation = XCTestExpectation(description: "Logout success")
        self.viewModel.requestLogout()
        self.viewModel.onLogoutSuccess = {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testRightMenuLogout_Failure() {
        let jsonData = """
            {
                "errors": [
                    {
                        "detail": "You are not authorized to revoke this token",
                        "code": "unauthorized_client"
                    }
                ]
            }
            """.data(using: .utf8)!
        self.mockSession.data = jsonData
        self.mockSession.urlResponse = HTTPURLResponse(
            url: URL(string: "http://example.com")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil)
        self.mockSession.error = nil
        let expectation = XCTestExpectation(description: "Logout failure")
        self.viewModel.requestLogout()
        self.viewModel.onLogoutFailed = { _ in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }

}
