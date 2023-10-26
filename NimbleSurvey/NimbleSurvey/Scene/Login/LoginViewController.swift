//
//  LoginViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - LoginViewController

class LoginViewController: UIViewController {

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: Internal

    @IBOutlet weak var logoIconHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoIconCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var textFieldBackgroundView: [UIView]!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var submitButtonView: UIButton!
    @IBOutlet weak var forgotButtonView: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logoIconImage: UIImageView!

    // MARK: Private

    private var logoPositionBelowNavBar: CGFloat = 0
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()
    private var viewModel = LoginViewModel()
}

// MARK: Action

extension LoginViewController: Action {
    @IBAction
    func didSelectForget(_: UIButton) {
        let forgotPasswordVC = ForgotPasswordViewController(viewModel: ForgotPasswordViewModel())
        self.navigationController?.pushViewController(forgotPasswordVC, animated: true)
    }

    @IBAction
    func didSelectLogin(_: UIButton) {
        Loader.shared.showLoader(view: self.view)
        self.viewModel.requestLogin(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
    }
}

// MARK: Updated

extension LoginViewController: Updated {

    // MARK: Internal

    internal func onInitialized() {
        self.onSuccess()
        self.onFailed()
    }

    // MARK: Private

    private func onSuccess() {
        self.viewModel.loginSuccess = {
            Loader.shared.hideLoader()
            let homeVC = HomeViewController(viewModel: HomeViewModel())
            self.navigationController?.pushViewController(homeVC, animated: true)
        }
    }

    private func onFailed() {
        self.viewModel.loginFailed = { message in
            Loader.shared.hideLoader()
            AlertUtility.showAlert(title: "Error", message: message)
        }

        self.viewModel.noRefreshTokenFound = {
            Loader.shared.hideLoader()
            AlertUtility.showAlert(title: "Error", message: Constants.Keys.errorNoRefreshTokenFound.localized())
        }
    }
}
