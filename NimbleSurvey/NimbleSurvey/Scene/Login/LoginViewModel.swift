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

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success(let model):
                guard let refreshToken = model.data?.attributes?.refreshToken else {
                    self.noRefreshTokenFound?()
                    return
                }
                guard let accessToken = model.data?.attributes?.accessToken else {
                    self.noAccessTokenFound?()
                    return
                }
                UserDefault().saveAccessToken(data: accessToken)
                UserDefault().saveRefreshToken(data: refreshToken)
                TokenRefresher.shared.startTimer()
                self.loginSuccess?()
            case .failure(let error):
                if case .serverError(let errorResponse) = error {
                    guard let errors = errorResponse.errors.first?.detail else {
                        self.loginFailed?(error.localizedDescription)
                        return
                    }
                    self.loginFailed?(errors)
                } else {
                    self.loginFailed?(error.localizedDescription)
                }
            }
        }
    }
}
