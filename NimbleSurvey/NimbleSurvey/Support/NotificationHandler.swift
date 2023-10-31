//
//  NotificationHandler.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/31/23.
//

import Foundation

class NotificationHandler {

    // MARK: Lifecycle

    // Private initializer to prevent creating different instances
    private init() {
        self.setupNotificationObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Internal

    // Singleton instance
    static let shared = NotificationHandler()

    // MARK: Private

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleRefreshTokenFailure),
            name: .refresherTokenOnFailure,
            object: nil)
    }

    @objc
    private func handleRefreshTokenFailure() {
        AlertUtility.showAlert(
            title: Constants.Keys.appName.localized(),
            message: Constants.Keys.refresherTokenError.localized())
        {
            AppUtility().loginScene()
        }
    }
}
