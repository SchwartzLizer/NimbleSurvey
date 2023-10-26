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

    // MARK: Internal

    var loginSuccess: (() -> Void)?
    var loginFailed: ((_ message: String) -> Void)?
    var noRefreshTokenFound: (() -> Void)?
    var noAccessTokenFound: (() -> Void)?

}

// MARK: RequestService

extension LoginViewModel: RequestService {
    public func requestLogin(email: String, password: String) {
        let router = Router.signIn(
            grantType: "password",
            email: email,
            password: password,
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { [weak self] (result: NetworkResult<LoginModel, NetworkError>) in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let model):
                if
                    let refreshToken = model.data?.attributes?.refreshToken,
                    let accessToken = model.data?.attributes?.accessToken
                {
                    UserDefault().saveAccessToken(data: accessToken)
                    UserDefault().saveRefreshToken(data: refreshToken)
                    TokenRefresher.shared.startTimer()
                    strongSelf.loginSuccess?()

                } else {
                    strongSelf.noRefreshTokenFound?()
                    strongSelf.noAccessTokenFound?()
                }

            case .failure(let error):
                switch error {
                case .serverError(let errorResponse):
                    let errorMessage = errorResponse.errors.first?.detail ?? error.localizedDescription
                    strongSelf.loginFailed?(errorMessage)
                default:
                    strongSelf.loginFailed?(error.localizedDescription)
                }
            }
        }
    }
}
