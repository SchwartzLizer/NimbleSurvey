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
    private init() {
        self.setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public

    // Timer instance
    public var refreshTokenTimer: Timer?

    // Time interval for the timer (e.g., 60 minutes). Adjust as needed.
    public let refreshInterval: TimeInterval = 7200 - 60

    // Selector that refreshes the token
    @objc
    public func refreshToken() {
        let router = Router.refreshToken(
            grantType: GrantType.refreshToken.rawValue,
            refreshToken: Keychain.shared.getRefreshToken(),
            clientID: Constants.ServiceKeys.key,
            clientSecret: Constants.ServiceKeys.secrect)

        NetworkManager.shared.request(router: router) { (result: NetworkResult<LoginModel, NetworkError>) in
            switch result {
            case .success(let data):
                guard let data = data.data?.attributes?.refreshToken else { return AlertUtility.showAlert(
                    title: Constants.Keys.appName.localized(),
                    message: Constants.Keys.refresherTokenError.localized())
                {
                    self.stopTimer()
                    let status = Keychain.shared.removeRefreshToken()
                    AppUtility().loginScene()
                }
                }
                self.startTimer()
                _ = Keychain.shared.saveRefreshToken(data: data)
                NotificationCenter.default.post(name: .refresherTokenOnSuccess, object: nil)
            case .failure:
                self.stopTimer()
                let status = Keychain.shared.removeRefreshToken()
                NotificationCenter.default.post(name: .refresherTokenOnFailureAutoLogin, object: nil)
            }
        }
    }

    // MARK: Internal

    // Singleton instance
    static let shared = TokenRefresher()

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

    // MARK: Private

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appDidEnterBackground),
            name: .refresherTokenAppDidEnterBackground,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.appWillEnterForeground),
            name: .refresherTokenAppWillEnterForeground,
            object: nil)
    }

    @objc
    private func appDidEnterBackground() {
        self.stopTimer()
    }

    @objc
    private func appWillEnterForeground() {
        self.refreshToken()
    }

}
