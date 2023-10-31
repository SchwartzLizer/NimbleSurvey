//
//  AppUtility.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - AppUtility

class AppUtility {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static let shared = AppUtility()

    // MARK: Private

    private var window: UIWindow? = UIApplication.shared.windows.first
}

// MARK: Scene

extension AppUtility {
    func loginScene() {
        let loginVC: LoginViewController? = getViewController(
            storyboardName: "Login",
            withIdentifier: "LoginViewController")
        guard let vc = loginVC else { return }
        let nav = UINavigationController(rootViewController: vc)
        setRootViewController(nav)
    }

    func checkTokenExist() -> Bool {
        if Keychain.shared.getRefreshToken() != "" {
            return true
        } else {
            return false
        }
    }

}

extension AppUtility {

    // MARK: Internal

    func animateWindow(duration: TimeInterval = 0.5) {
        guard
            let window = window
        else { return }
        UIView.transition(
            with: window,
            duration: duration,
            options: [.transitionCrossDissolve],
            animations: nil,
            completion: nil)
    }

    // MARK: Private

    // MARK: - Private Methods

    private func getViewController<T>(storyboardName: String, withIdentifier identifier: String) -> T? {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }

    private func setRootViewController(_ viewController: UIViewController) {
        self.window?.rootViewController = viewController
        self.window?.makeKeyAndVisible()
        self.animateWindow()
    }
}
