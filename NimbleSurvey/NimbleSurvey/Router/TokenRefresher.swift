//
//  TokenRefresher.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

class TokenRefresher {

    // MARK: Lifecycle

    // Private initializer to prevent creating different instances.
    private init() { }

    // MARK: Public

    // Timer instance
    public var refreshTokenTimer: Timer?

    // Time interval for the timer (e.g., 60 minutes). Adjust as needed.
    public let refreshInterval: TimeInterval = 7200 - 60

    // Selector that refreshes the token
    @objc
    public func refreshToken() {
        let router = Router.refreshToken(
            grantType: "refresh_token",
            refreshToken: Keychain().getRefreshToken() ?? "",
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success(let data):
                self.onSuccess?()
                guard let data = data.data?.attributes?.refreshToken else { return AlertUtility.showAlert(
                    title: "Error",
                    message: Constants.Keys.refresherTokenError.localized())
                {
                    AppUtility().loginScene()
                }
                }
                Keychain().saveRefreshToken(data: data)
            case .failure:
                self.onFailed?()
                AlertUtility.showAlert(title: "Error", message: Constants.Keys.refresherTokenError.localized()) {
                    AppUtility().loginScene()
                }
            }
        }
    }

    // MARK: Internal

    // Singleton instance
    static let shared = TokenRefresher()

    var onSuccess: (()->Void)?
    var onFailed: (()->Void)?

    // Method to start the timer
    func startTimer() {
        if self.refreshTokenTimer == nil {
            self.refreshTokenTimer = Timer.scheduledTimer(
                timeInterval: self.refreshInterval,
                target: self,
                selector: #selector(self.refreshToken),
                userInfo: nil,
                repeats: true)
        }
    }

    // Method to stop the timer
    func stopTimer() {
        if self.refreshTokenTimer != nil {
            self.refreshTokenTimer?.invalidate()
            self.refreshTokenTimer = nil
        }
    }

}
