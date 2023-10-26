//
//  AlertUtility.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - AlertUtility

class AlertUtility {

    // MARK: - Alert with OK Button

    static func showAlert(title: String?, message: String?, completion: (() -> Void)? = nil) {
        guard let topVC = UIApplication.topViewController() else { return }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Constants.Alert.okButtonTitle, style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        topVC.present(alertController, animated: true, completion: nil)
    }


    // MARK: - Alert with OK and Cancel Buttons

    static func showConfirmationAlert(
        title: String?,
        message: String?,
        okButtonTitle: String = Constants.Alert.okButtonTitle,
        cancelButtonTitle: String = Constants.Alert.cancelButtonTitle,
        okCompletion: (() -> Void)? = nil,
        cancelCompletion: (() -> Void)? = nil)
    {
        guard let topVC = UIApplication.topViewController() else { return }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: okButtonTitle, style: .default) { _ in
            okCompletion?()
        }
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            cancelCompletion?()
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        topVC.present(alertController, animated: true, completion: nil)
    }


    // MARK: - Action Sheet

    static func showActionSheet(title: String?, message: String?, actions: [UIAlertAction]) {
        guard let topVC = UIApplication.topViewController() else { return }

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        for action in actions {
            alertController.addAction(action)
        }
        // This is to handle iPads, otherwise it will crash because action sheets on iPads need a source view or bar button item.
        if let popoverController = alertController.popoverPresentationController, let sourceView = topVC.view {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = CGRect(x: sourceView.bounds.midX, y: sourceView.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        topVC.present(alertController, animated: true, completion: nil)
    }

}

// MARK: - Constants.Alert

extension Constants {
    enum Alert {
        static let okButtonTitle = "OK"
        static let cancelButtonTitle = "Cancel"
    }
}

extension UIApplication {

    // MARK: Internal

    class func topViewController(base: UIViewController? = keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return self.topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return self.topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return self.topViewController(base: presented)
        }
        return base
    }

    // MARK: Private

    private class var keyWindow: UIWindow? {
        // For iOS 13 and later
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first(where: { $0.isKeyWindow })
        } else {
            // For iOS 12 and earlier
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
}
