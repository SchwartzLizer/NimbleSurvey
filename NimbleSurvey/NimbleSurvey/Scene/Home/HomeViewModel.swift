//
//  HomeViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - HomeViewModel

final class HomeViewModel: ViewModel {

    // MARK: Lifecycle

    init() { }

    // MARK: Public

    public var datas: [SurveyListModelData] = []
    public var profileData = UserProfileAttributes(email: "", name: "", avatarURL: "")
    public var lists: [HomeDataModel] = []

    // MARK: Internal

    var onUpdated: (() -> Void)?
    var onScrollUpdated: ((_ list:HomeDataModel) -> Void)?
    var onFailed: ((_ message:String) -> Void)?

    // MARK: Private

    private var page = 1
}

// MARK: RequestService

extension HomeViewModel: RequestService {
    public func requestData(accessToken:String) {
        let group = DispatchGroup()

        // Request Survey List
        group.enter()
        self.requestSurveyList(token: accessToken) {
            group.leave()
        }

        // Request User Profile
        group.enter()
        self.requestUserProfile(token: accessToken) {
            group.leave()
        }

        group.notify(queue: .main) {
            self.onUpdated?()
        }
    }

    public func pullToRefresh() {
        self.requestData(accessToken: UserDefault().getAccessToken() ?? "")
    }

    public func clearData() {
        self.datas = []
        self.profileData = UserProfileAttributes(email: "", name: "", avatarURL: "")
        self.lists = []
    }

    public func requestSurveyList(token:String,completion: @escaping () -> Void) {
        let router = Router.surveyList(
            page: 1,
            perPage: 5,
            bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<SurveyListModel, NetworkError>) in
            switch result {
            case .success(let success):
                guard let data = success.data else { break }
                let dataManager = DataManager.shared
                dataManager.saveSurveyToCoreData(surveyList: success)
                dataManager.fetchAndPrintSurveys()
                UserDefault().saveSurveyList(data: data)
                print("Data Saved")
                print("Show Save Data \(UserDefault().getSurveyList())")
                FilesManagerHelper.shared?.saveSurveys(surveys: data, withName: "Survey")
                print("Files Save")
                print("Read File Save \(FilesManagerHelper.shared?.readSurveys(withName: "Survey"))")
                self.datas = data
                self.lists = self.processData(data: data)
                completion()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    guard let errors = errorResponse.errors.first?.detail else {
                        self.onFailed?(error.localizedDescription)
                        completion()
                        return
                    }
                    self.onFailed?(errors)
                    completion()
                } else {
                    self.onFailed?(error.localizedDescription)
                    completion()
                }
            }
        }
    }

    public func requestUserProfile(token:String,completion: @escaping () -> Void) {
        let router = Router.userProfile(bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<UserProfileModel, NetworkError>) in
            switch result {
            case .success(let success):
                guard let data = success.data?.attributes else { break }
                self.profileData = data
                completion()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    guard let errors = errorResponse.errors.first?.detail else {
                        self.onFailed?(error.localizedDescription)
                        completion()
                        return
                    }
                    self.onFailed?(errors)
                    completion()
                } else {
                    self.onFailed?(error.localizedDescription)
                    completion()
                }
            }
        }
    }
}

// MARK: ProcessDataSource

extension HomeViewModel: ProcessDataSource {
    private func processData(data: [SurveyListModelData]) -> [HomeDataModel] {
        return data.map { HomeDataModel(title: $0.attributes?.title, subTitle: $0.attributes?.description) }
    }
}

// MARK: Logic

extension HomeViewModel: Logic {
    public func scrollViewUpdate(page: Int) -> HomeDataModel {
        self.onScrollUpdated?(self.lists[page])
        return self.lists[page]
    }

    public func processDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "EEEE, MMMM d"
        let formattedDate = dateFormatter.string(from: currentDate).uppercased()
        return formattedDate
    }
}
