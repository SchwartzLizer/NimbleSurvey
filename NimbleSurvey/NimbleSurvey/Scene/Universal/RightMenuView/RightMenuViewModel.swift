//
//  RightMenuViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - RightMenuViewModel

final class RightMenuViewModel: ViewModel {

    // MARK: Lifecycle

    init(model: RightMenuModel) {
        self.RightMenuModel = model
    }

    // MARK: Internal

    var RightMenuModel: RightMenuModel

    var onLogoutSuccess: (() -> Void)?
    var onLogoutFailed: ((_ message: String) -> Void)?

}

// MARK: RequestService

extension RightMenuViewModel: RequestService {
    public func requestLogout() {
        let router = Router.logout(
            token: UserDefault().getAccessToken() ?? "",
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<UserProfileModel, NetworkError>) in
            switch result {
            case .success:
                self.onLogoutSuccess?()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    guard let errors = errorResponse.errors.first?.detail else {
                        self.onLogoutFailed?(error.localizedDescription)
                        return
                    }
                    self.onLogoutFailed?(errors)
                } else {
                    self.onLogoutFailed?(error.localizedDescription)
                }
            }
        }
    }
}
