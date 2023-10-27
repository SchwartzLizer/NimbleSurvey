//
//  HomeUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class HomeUnitTest: XCTestCase {

    var viewModel: HomeViewModel!
    var token: String?

    override func setUp() {
        super.setUp()
        self.viewModel = HomeViewModel()
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
                guard let accessToken = value.data?.attributes?.accessToken
                else { return XCTFail("Error, no token in response") }
                self.token = accessToken
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

    // MARK: Survey
    // MARK: 404 - invalid page number
    func testSurveyInvalidPageNumber() {
        let expectation = self.expectation(description: "Survey should invalid page number")
        guard let token = self.token else {
            XCTFail("Token not found")
            return
        }
        let pageNumber = -100
        let pageSize = 2

        let router = Router.surveyList(page: pageNumber, perPage: pageSize, bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<SurveyListModel, NetworkError>) in
            switch result {
            case .success:
                XCTFail("Expected failure for 'Survey should invalid page number' but got success.")
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

    // MARK: 200 - valid params
    func testSurveyValidParams() {
        let expectation = self.expectation(description: "Survey should success")
        guard let token = self.token else {
            XCTFail("Token not found")
            return
        }
        let pageNumber = 100
        let pageSize = 2

        let router = Router.surveyList(page: pageNumber, perPage: pageSize, bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<SurveyListModel, NetworkError>) in
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

    // MARK: User Profile
    // MARK: 200 - success
    func testRequestUser() {
        let expectation = self.expectation(description: "Request user should success")
        guard let token = self.token else {
            XCTFail("Token not found")
            return
        }

        let router = Router.userProfile(bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<UserProfileModel, NetworkError>) in
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

    func testClearData() {
        self.viewModel.clearData()
        XCTAssertEqual(self.viewModel.datas.count, 0)
        XCTAssertEqual(self.viewModel.lists.count, 0)
    }

    func testProcessDate() {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        let expectedDate = dateFormatter.string(from: currentDate).uppercased()
        let actualDate = self.viewModel.processDate()
        XCTAssertEqual(
            actualDate,
            expectedDate,
            "The processDate function should return the current date in 'EEEE, MMMM d' format.")
    }

    func testScrollViewUpdate() {
        let expectation = self.expectation(description: "onScrollUpdated is called")
        var callbackData: HomeDataModel?
        let mockList = [
            HomeDataModel(title: "Title1", subTitle: "Subtitle1"),
            HomeDataModel(title: "Title2", subTitle: "Subtitle2"),
            HomeDataModel(title: "Title3", subTitle: "Subtitle3"),
        ]
        self.viewModel.lists = mockList
        self.viewModel.onScrollUpdated = { data in
            callbackData = data
            expectation.fulfill()
        }
        let testPage = 1
        let result = self.viewModel.scrollViewUpdate(page: testPage)
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectations errored: \(error)")
            }
        }
        XCTAssertEqual(callbackData, self.viewModel.lists[testPage], "Callback should be triggered with the correct data.")
        XCTAssertEqual(result, self.viewModel.lists[testPage], "Should return the correct survey model for the page.")
    }

}
