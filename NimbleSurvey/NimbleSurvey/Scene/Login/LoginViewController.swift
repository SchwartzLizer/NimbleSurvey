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

// MARK: ApplyTheme

extension LoginViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.stackView.isHidden = true
        self.stackView.alpha = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animateAndResizeImage()
            self.blurBackgroundImage()

            UIView.animate(withDuration: 1.0) {
                self.stackView.isHidden = false
                self.stackView.alpha = 1
            }
        }
        self.applyThemeBackgroundTextField()
        self.applyThemeSubmitButton()
        self.applyThemeForgetButton()
    }

    // MARK: Private

    private func animateAndResizeImage() {
        self.logoPositionBelowNavBar = UIApplication.shared.statusBarFrame.height + 110
        let logoCenterToEndPosition = self.logoPositionBelowNavBar + (self.logoIconImage.frame.height / 2.0)
        let newCenterYConstant = logoCenterToEndPosition - (self.view.frame.height / 2.0)
        let scale: CGFloat = 0.70
        let scaledHeight = self.logoIconImage.frame.size.height * scale
        UIView.animate(withDuration: 1, animations: {
            self.logoIconCenterYConstraint.constant = newCenterYConstant
            self.logoIconHeightConstraint.constant = scaledHeight
            self.view.layoutIfNeeded()
        })
    }

    private func blurBackgroundImage() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.backgroundImageView.bounds
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.alpha = 0
        self.backgroundImageView.addSubview(blurredEffectView)
        UIView.animate(withDuration: 1.0) {
            blurredEffectView.alpha = 1
        }
    }

    private func applyThemeBackgroundTextField() {
        for view in self.textFieldBackgroundView {
            view.applyThemeView(background: self.theme.textfieldBackgroundColor, radius: Constants.Radius.cornerRadiusCard)
            let blurEffect = UIBlurEffect(style: .light)
            let blurredEffectView = UIVisualEffectView(effect: blurEffect)
            blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurredEffectView.layer.cornerRadius = Constants.Radius.cornerRadiusCard
            blurredEffectView.alpha = 1
            blurredEffectView.clipsToBounds = true
            blurredEffectView.frame = view.bounds
            view.addSubview(blurredEffectView)
        }
        self.passwordTextField.borderStyle = .none
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.Keys.passwordTF.localized(),
            attributes: [NSAttributedString.Key.foregroundColor: self.theme.placeholderLabelColor])
        self.passwordTextField.font = self.font.textLabelFontSize
        self.passwordTextField.textColor = self.theme.textfieldLabelColor

        self.emailTextField.borderStyle = .none
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.Keys.emailTF.localized(),
            attributes: [NSAttributedString.Key.foregroundColor: self.theme.placeholderLabelColor])
        self.emailTextField.font = self.font.textLabelFontSize
        self.emailTextField.textColor = self.theme.textfieldLabelColor
    }

    private func applyThemeSubmitButton() {
        self.submitButtonView.applyThemeButton(
            text: Constants.Keys.loginBTN,
            font: self.font.buttonFontSize,
            color: self.theme.buttonTextColor,
            round: Constants.Radius.cornerRadiusCard,
            backgroundColor: self.theme.buttonBackgroundColor,
            borderColor: self.theme.buttonBackgroundColor)
    }

    private func applyThemeForgetButton() {
        self.forgotButtonView.applyThemeButton(
            text: Constants.Keys.forgotBTN,
            font: self.font.forgotFontSize,
            color: self.theme.forgotTextColor)
    }
}

