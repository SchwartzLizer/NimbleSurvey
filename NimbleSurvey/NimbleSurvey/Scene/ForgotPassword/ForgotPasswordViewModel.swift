//
//  ForgotPasswordViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - ForgotPasswordViewModel

final class ForgotPasswordViewModel: ViewModel {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    var resetFailed: ((_ message: String) -> Void)?
    var resetSuccess: (() -> Void)?
}

// MARK: RequestService

extension ForgotPasswordViewModel: RequestService {
    public func requestForgotPassword(email: String) {
        let router = Router.forgotPassword(
            email: email,
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<ForgotPassword, NetworkError>) in
            switch result {
            case .success:
                self.resetSuccess?()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    guard let errors = errorResponse.errors.first?.detail else {
                        self.resetFailed?(error.localizedDescription)
                        return
                    }
                    self.resetFailed?(errors)
                } else {
                    self.resetFailed?(error.localizedDescription)
                }
            }
        }
    }
}
