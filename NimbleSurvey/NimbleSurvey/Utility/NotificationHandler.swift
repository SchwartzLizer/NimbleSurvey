//
//  NotificationHandler.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/31/23.
//

import Foundation

class NotificationHandler {

    // MARK: Lifecycle

    public init() {
        self.setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public

    @objc
    public func handleRefreshTokenFailure() {
        alertUtility.showAlert(
            title: Constants.Keys.appName.localized(),
            message: Constants.Keys.refresherTokenError.localized())
        {
            self.appUtility.loginScene()
        }
    }

    // MARK: Internal

    // Singleton instance
    static let shared = NotificationHandler()
    var alertUtility: AlertShowing.Type = AlertUtility.self
    var appUtility: AppUtilityProtocol = AppUtility()

    // MARK: Private

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleRefreshTokenFailure),
            name: .refresherTokenOnFailure,
            object: nil)
    }

}
