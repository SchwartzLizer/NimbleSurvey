//
//  HomeUnitTest.swift
//  NimbleSurveyTests
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import XCTest

final class HomeUnitTest: XCTestCase {

    var viewModel: HomeViewModel!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        self.mockSession = MockURLSession()
        NetworkManager.shared.setSession(self.mockSession)
        self.viewModel = HomeViewModel()
    }

    override func tearDown() {
        UserDefault().removeSurveyList()
        self.mockSession = nil
        self.viewModel = nil
        super.tearDown()
    }

    func testHome_RequestSurveyList_Success() {
        let jsonData = """
            {
                "data": [
                    {
                        "id": "d5de6a8f8f5f1cfe51bc",
                        "type": "survey",
                        "attributes": {
                            "title": "Scarlett Bangkok",
                            "description": "We'd love ot hear from you!",
                            "thank_email_above_threshold": "",
                            "thank_email_below_threshold": "",
                            "is_active": true,
                            "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                            "created_at": "2017-01-23T07:48:12.991Z",
                            "active_at": "2015-10-08T07:04:00.000Z",
                            "inactive_at": null,
                            "survey_type": "Restaurant"
                        },
                        "relationships": {
                            "questions": {
                                "data": [
                                    {
                                        "id": "d3afbcf2b1d60af845dc",
                                        "type": "question"
                                    }
                                ]
                            }
                        }
                    }
            ],
                "meta": {
                    "page": 1,
                    "pages": 10,
                    "page_size": 2,
                    "records": 20
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
        let expectation = XCTestExpectation(description: "Survey list request completed successfully")
        self.viewModel.requestSurveyList(token: "testAccessToken") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(self.viewModel.datas.count, 1)
    }

    func testHome_RequestUserProfile_Success() {
        let jsonData = """
            {
                "data": {
                    "id": "1",
                    "type": "user",
                    "attributes": {
                        "email": "dev@nimblehq.co",
                        "name": "Team Nimble",
                        "avatar_url": "https://secure.gravatar.com/avatar/6733d09432e89459dba795de8312ac2d"
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
        let expectation = XCTestExpectation(description: "User profile request completed successfully")
        self.viewModel.requestUserProfile(token: "testAccessToken") {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(self.viewModel.profileData.email, "dev@nimblehq.co")
        XCTAssertEqual(self.viewModel.profileData.name, "Team Nimble")
        XCTAssertEqual(
            self.viewModel.profileData.avatarURL,
            "https://secure.gravatar.com/avatar/6733d09432e89459dba795de8312ac2d")
    }

    func testHome_HandleFailureErrorWithLocalData() {
        let mockSurveyListData: [SurveyListModelData] = [
            SurveyListModelData(
                id: "test",
                type: "test",
                attributes: SurveyListModelAttributes(
                    title: "test",
                    description: "test",
                    thankEmailAboveThreshold: "test",
                    thankEmailBelowThreshold: "test",
                    isActive: false,
                    coverImageURL: "test",
                    createdAt: "test",
                    activeAt: "test",
                    inactiveAt: "test",
                    surveyType: "test"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test",
                    type: "test")]))),
        ]
        let profileAttributes = UserProfileAttributes(
            email: "test@email.com",
            name: "John Doe",
            avatarURL: "https://example.com/avatar.jpg")
        UserDefault().saveProfile(data: profileAttributes)
        UserDefault().saveSurveyList(data: mockSurveyListData)
        let mockError = NetworkError.serverError(ErrorResponse(errors: []))
        self.viewModel.handleFailureError(mockError)
        XCTAssertEqual(self.viewModel.datas, mockSurveyListData)
        XCTAssertEqual(self.viewModel.profileData.email, profileAttributes.email)
        XCTAssertEqual(self.viewModel.profileData.name, profileAttributes.name)
        XCTAssertEqual(self.viewModel.profileData.avatarURL, profileAttributes.avatarURL)
    }

    func testHome_HandleFailureError_ServerError() {
        let expectation = XCTestExpectation(description: "onFailed closure called")
        self.viewModel.onFailed = { errorMessage in
            XCTAssertEqual(errorMessage, "Server error message")
            expectation.fulfill()
        }
        let mockServerError = NetworkError.serverError(ErrorResponse(errors: [ErrorResponse.Error(
            source: nil,
            detail: "Server error message",
            code: "500")]))
        self.viewModel.handleFailureError(mockServerError)
        wait(for: [expectation], timeout: 5.0)
    }

    func testHome_CheckLocalDeviceData_SurveyListData() {
        let mockSurveyListData: [SurveyListModelData] = [
            SurveyListModelData(
                id: "test",
                type: "test",
                attributes: SurveyListModelAttributes(
                    title: "test",
                    description: "test",
                    thankEmailAboveThreshold: "test",
                    thankEmailBelowThreshold: "test",
                    isActive: false,
                    coverImageURL: "test",
                    createdAt: "test",
                    activeAt: "test",
                    inactiveAt: "test",
                    surveyType: "test"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test",
                    type: "test")]))),
        ]
        UserDefault().saveSurveyList(data: mockSurveyListData)
        let hasSurveyListData = self.viewModel.checkLocalDeviceData()
        XCTAssertTrue(hasSurveyListData)
    }

    func testHome_CheckLocalDeviceDataWithoutSurveyListData() {
        UserDefault().removeSurveyList()
        let hasSurveyListData = self.viewModel.checkLocalDeviceData()
        XCTAssertFalse(hasSurveyListData)
    }

    func testHome_ProcessData() {
        let surveyListData: [SurveyListModelData] = [
            SurveyListModelData(
                id: "test",
                type: "test",
                attributes: SurveyListModelAttributes(
                    title: "test",
                    description: "test",
                    thankEmailAboveThreshold: "test",
                    thankEmailBelowThreshold: "test",
                    isActive: false,
                    coverImageURL: "test",
                    createdAt: "test",
                    activeAt: "test",
                    inactiveAt: "test",
                    surveyType: "test"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test",
                    type: "test")]))),
            SurveyListModelData(
                id: "test2",
                type: "test2",
                attributes: SurveyListModelAttributes(
                    title: "test2",
                    description: "test2",
                    thankEmailAboveThreshold: "test2",
                    thankEmailBelowThreshold: "test2",
                    isActive: false,
                    coverImageURL: "test2",
                    createdAt: "test2",
                    activeAt: "test2",
                    inactiveAt: "test2",
                    surveyType: "test2"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test2",
                    type: "test2")]))),
        ]
        let homeDataList = self.viewModel.processData(data: surveyListData)
        XCTAssertEqual(homeDataList.count, surveyListData.count)
        XCTAssertEqual(homeDataList[0].title, "test")
        XCTAssertEqual(homeDataList[0].subTitle, "test")
        XCTAssertEqual(homeDataList[1].title, "test2")
        XCTAssertEqual(homeDataList[1].subTitle, "test2")
    }

    func testHome_ScrollViewUpdate() {
        let mockHomeDataModel = HomeDataModel(title: "Test Title", subTitle: "Test Subtitle")
        self.viewModel.lists = [mockHomeDataModel]
        let expectation = XCTestExpectation(description: "onScrollUpdated closure called")
        self.viewModel.onScrollUpdated = { updatedModel in
            XCTAssertEqual(updatedModel, mockHomeDataModel)
            expectation.fulfill()
        }
        let returnedHomeDataModel = self.viewModel.scrollViewUpdate(page: 0)
        XCTAssertNotNil(returnedHomeDataModel)
        if let unwrappedHomeDataModel = returnedHomeDataModel {
            XCTAssertEqual(unwrappedHomeDataModel, mockHomeDataModel)
        } else {
            XCTFail("Returned HomeDataModel is nil")
        }
        wait(for: [expectation], timeout: 5.0)
    }

    func testHome_ProcessDate() {
        let formattedDate = self.viewModel.processDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DateFormat.eeeeMMMMd
        let currentDate = Date()
        let expectedFormattedDate = dateFormatter.string(from: currentDate).uppercased()
        XCTAssertEqual(formattedDate, expectedFormattedDate)
    }

    func testHome_SaveSurveyData() {
        let viewModel = HomeViewModel()
        let surveyListData: [SurveyListModelData] = [
            SurveyListModelData(
                id: "test",
                type: "test",
                attributes: SurveyListModelAttributes(
                    title: "test",
                    description: "test",
                    thankEmailAboveThreshold: "test",
                    thankEmailBelowThreshold: "test",
                    isActive: false,
                    coverImageURL: "test",
                    createdAt: "test",
                    activeAt: "test",
                    inactiveAt: "test",
                    surveyType: "test"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test",
                    type: "test")]))),
            SurveyListModelData(
                id: "test2",
                type: "test2",
                attributes: SurveyListModelAttributes(
                    title: "test2",
                    description: "test2",
                    thankEmailAboveThreshold: "test2",
                    thankEmailBelowThreshold: "test2",
                    isActive: false,
                    coverImageURL: "test2",
                    createdAt: "test2",
                    activeAt: "test2",
                    inactiveAt: "test2",
                    surveyType: "test2"),
                relationships: SurveyListModelRelationships(questions: SurveyListModelQuestions(data: [QuestionsData(
                    id: "test2",
                    type: "test2")]))),
        ]
        let mockSurveyListModel = SurveyListModel(
            data: surveyListData,
            meta: SurveyListModelMeta(page: 1, pages: 1, pageSize: 1, records: 1))
        viewModel.saveSurveyList(data: mockSurveyListModel)
        if let savedData = UserDefault().loadSurveyList() {
            XCTAssertNotNil(savedData)
        } else {
            XCTFail("Failed to retrieve saved survey data")
        }
    }

    func testHome_SaveProfileData() {
        // Given
        let profileAttributes = UserProfileAttributes(
            email: "test@email.com",
            name: "John Doe",
            avatarURL: "https://example.com/avatar.jpg")

        // When
        self.viewModel.saveProfile(data: profileAttributes)

        // Then
        if let savedData = UserDefault().loadProfile() {
            XCTAssertNotNil(savedData)
        } else {
            XCTFail("Failed to retrieve saved profile data")
        }
    }

}
