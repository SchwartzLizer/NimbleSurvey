//
//  ForgotPasswordViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    // MARK: Lifecycle

    required init(viewModel: ForgotPasswordViewModel) {
        self.ViewModel = viewModel
        super.init(nibName: ForgotPasswordViewController.identifier, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var resetButtonView: UIButton!

    // MARK: Private

    private var notificationView: UIView!
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()
    private var ViewModel: ForgotPasswordViewModel
    private var navbar: CGFloat = 0

}

extension ForgotPasswordViewController: Action {
    @IBAction
    func didSelectReset(_: UIButton) {
        Loader.shared.showLoader(view: self.view)
        self.ViewModel.requestForgotPassword(email: self.emailTextField.text ?? "")
    }

    @objc
    func backAction(_: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }


    @objc
    func hideNotification() {
        // Animate the retraction of the notification view
        let yPosition = UIApplication.shared.statusBarFrame.height + 62
        UIView.animate(withDuration: 0.5) {
            self.notificationView.frame = CGRect(x: 0, y: -abs(yPosition), width: self.view.frame.size.width, height: yPosition)
        }
    }

    func showNotification() {
        // Animate the dropping of the notification view
        UIView.animate(withDuration: 0.5, animations: {
            self.notificationView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 116)
        }) { completed in
            if completed {
                // Automatically dismiss after 3 seconds
                self.perform(#selector(self.hideNotification), with: nil, afterDelay: 2.0)
                self.emailTextField.text = ""
            }
        }
    }
}

extension ForgotPasswordViewController: Updated {

    // MARK: Internal

    internal func onInitialized() {
        self.onSuccess()
        self.onFailure()
    }

    // MARK: Private

    private func onSuccess() {
        self.ViewModel.resetSuccess = {
            Loader.shared.hideLoader()
            self.showNotification()
        }
    }

    private func onFailure() {
        self.ViewModel.resetFailed = { message in
            Loader.shared.hideLoader()
            AlertUtility.showAlert(title: "Error", message: message)
        }
    }

}

