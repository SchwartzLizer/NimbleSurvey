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
                self.save(data: success)
                self.datas = data
                self.lists = self.processData(data: data)
                completion()
            case .failure(let error):
                self.handleFailureError(error,isServeyRequest: true)
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
                self.handleFailureError(error)
            }
        }
    }

    // MARK: Private

    private func handleFailureError(_ error: NetworkError,isServeyRequest _:Bool = false) {
        if self.checkLocalDeviceData() {
            self.datas = UserDefault().getSurveyList() ?? []
            self.lists = self.processData(data: self.datas)
            self.onUpdated?()
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

    private func checkLocalDeviceData() -> Bool {
        return UserDefault().getSurveyList() != nil
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

        dateFormatter.dateFormat = Constants.DateFormat.eeeeMMMMd
        let formattedDate = dateFormatter.string(from: currentDate).uppercased()
        return formattedDate
    }

    public func save(data: SurveyListModel) {
        guard let data = data.data else { return }
        UserDefault().saveSurveyList(data: data)
    }

}
