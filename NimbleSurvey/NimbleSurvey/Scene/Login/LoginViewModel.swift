//
//  LoginViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - LoginViewModel

final class LoginViewModel: ViewModel {

    // MARK: Lifecycle

    init() { }

    // MARK: Public

    public var loginSuccess: (() -> Void)?
    public var loginFailure: ((String) -> Void)?
    public var noRefreshTokenFound: (() -> Void)?
    public var noAccessTokenFound: (() -> Void)?

}

// MARK: RequestService

extension LoginViewModel: RequestService {

    // MARK: Public

    public func requestLogin(email: String, password: String) {
        let router = Router.signIn(
            grantType: GrantType.password.rawValue,
            email: email,
            password: password,
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { [weak self] (result: NetworkResult<LoginModel, NetworkError>) in
            guard let self = self else { return }

            switch result {
            case .success(let model):
                if
                    let refreshToken = model.data?.attributes?.refreshToken,
                    let accessToken = model.data?.attributes?.accessToken
                {
                    Keychain().saveAccessToken(data: accessToken)
                    Keychain().saveRefreshToken(data: refreshToken)
                    TokenRefresher.shared.startTimer()
                    self.loginSuccess?()

                } else {
                    self.noRefreshTokenFound?()
                    self.noAccessTokenFound?()
                }

            case .failure(let error):
                let errorMessage = self.errorMessage(from: error)
                self.loginFailure?(errorMessage)
            }
        }
    }

    // MARK: Private

    private func errorMessage(from error: NetworkError) -> String {
        switch error {
        case .serverError(let errorResponse):
            return errorResponse.errors.first?.detail ?? "An unknown server error occurred."
        default:
            return error.localizedDescription
        }
    }
}
