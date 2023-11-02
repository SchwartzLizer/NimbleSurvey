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

    // MARK: Public

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
        self.requestData(accessToken: Keychain.shared.getAccessToken())
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
                self.handleSuccessSurveyList(data: success)
                completion()
            case .failure(let error):
                self.handleFailureError(error)
                completion()
            }
        }
    }

    public func requestUserProfile(token:String,completion: @escaping () -> Void) {
        let router = Router.userProfile(bearerToken: token)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<UserProfileModel, NetworkError>) in
            switch result {
            case .success(let success):
                self.handleSuccessUserProfile(data: success)
                completion()
            case .failure(let error):
                self.handleFailureError(error)
            }
        }
    }

    public func handleSuccessSurveyList(data: SurveyListModel) {
        self.saveSurveyList(data: data)
        guard let dataListModel = data.data else { return }
        self.datas = dataListModel
        self.lists = self.processData(data: dataListModel)
    }

    public func handleSuccessUserProfile(data: UserProfileModel) {
        guard let data = data.data?.attributes else { return }
        self.saveProfile(data: data)
        self.profileData = data
    }

    public func handleFailureError(_ error: NetworkError) {
        if self.checkLocalDeviceData() {
            self.datas = UserDefault().loadSurveyList() ?? []
            self.lists = self.processData(data: self.datas)
            self.profileData = UserDefault().loadProfile() ?? UserProfileAttributes(email: "", name: "", avatarURL: "")
        } else {
            let detailedError: Error
            if case .serverError(let errorResponse) = error, let serverMessage = errorResponse.errors.first?.detail {
                detailedError = NSError(
                    domain: "Server Error",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: serverMessage])
            } else {
                detailedError = error
            }
            self.onFailed?(detailedError.localizedDescription)
        }
    }

}

// MARK: ProcessDataSource

extension HomeViewModel: ProcessDataSource {
    internal func processData(data: [SurveyListModelData]) -> [HomeDataModel] {
        return data.map { HomeDataModel(title: $0.attributes?.title, subTitle: $0.attributes?.description) }
    }
}

// MARK: Logic

extension HomeViewModel: Logic {
    public func scrollViewUpdate(page: Int) -> HomeDataModel? {
        guard page >= 0 && page < self.lists.count else {
            return nil
        }
        self.onScrollUpdated?(self.lists[page])
        return self.lists[page]
    }

    public func processDate() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = Constants.DateFormat.eeeeMMMMd
        let formattedDate = dateFormatter.string(from: currentDate).uppercased()
        return formattedDate
    }

    public func saveSurveyList(data: SurveyListModel) {
        guard let data = data.data else { return }
        UserDefault().saveSurveyList(data: data)
    }

    public func saveProfile(data: UserProfileAttributes) {
        UserDefault().saveProfile(data: data)
    }

    internal func checkLocalDeviceData() -> Bool {
        return UserDefault().loadSurveyList() != nil && UserDefault().loadProfile() != nil
    }

}
