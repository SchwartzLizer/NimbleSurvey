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
                self.handleTokens(model: model)
            case .failure(let error):
                let errorMessage = self.errorMessage(from: error)
                self.loginFailure?(errorMessage)
            }
        }
    }

    // MARK: Internal

    internal func handleRefreshToken(model: LoginModel) {
        guard let refreshToken = model.data?.attributes?.refreshToken, !refreshToken.isEmpty else {
            self.noRefreshTokenFound?()
            return
        }
        _ = Keychain.shared.saveRefreshToken(data: refreshToken)
    }

    internal func handleAccessToken(model: LoginModel) {
        guard let accessToken = model.data?.attributes?.accessToken, !accessToken.isEmpty else {
            self.noAccessTokenFound?()
            return
        }
        _ = Keychain.shared.saveAccessToken(data: accessToken)
        self.loginSuccess?()
    }

    // MARK: Private

    private func handleTokens(model: LoginModel) {
        self.handleRefreshToken(model: model)
        self.handleAccessToken(model: model)
    }

    private func errorMessage(from error: NetworkError) -> String {
        switch error {
        case .serverError(let errorResponse):
            return errorResponse.errors.first?.detail ?? "An unknown server error occurred."
        default:
            return error.localizedDescription
        }
    }

}
