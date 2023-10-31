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
        self.onInitialized()
        self.setupUI()
        self.applyTheme()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.onDidDisappear()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    // MARK: Internal

    @IBAction
    func didSelectForget(_: UIButton) {
        self.endEditTextField()
        self.navigationController?.pushViewController(
            ForgotPasswordViewController(viewModel: ForgotPasswordViewModel()),
            animated: true)
    }

    @IBAction
    func didSelectLogin(_: UIButton) {
        self.endEditTextField()
        Loader.shared.showLoader(view: self.view)
        self.viewModel.requestLogin(email: self.emailTextField.text ?? "", password: self.passwordTextField.text ?? "")
    }

    // MARK: Private

    private func clearTextField() {
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
    }

    private func showAlertAndClearText(message: String) {
        AlertUtility.showAlert(title: Constants.Keys.appName.localized(), message: message) { [weak self] in
            self?.clearTextField()
        }
    }

    private func endEditTextField() {
        self.passwordTextField.endEditing(true)
        self.emailTextField.endEditing(true)
    }

    @objc
    private func refresherTokenSuccess() {
        self.goToHome()
    }

    @objc
    private func refreshTokenFailure() {
        DispatchQueue.main.async {
            Loader.shared.hideLoader()
            self.stackView.isHidden = false
            self.stackView.alpha = 1
        }
    }

    private func goToHome() {
        DispatchQueue.main.async {
            _ = NotificationHandler.shared // Start observing notification
            Loader.shared.hideLoader()
            self.navigationController?.pushViewController(HomeViewController(viewModel: HomeViewModel()), animated: true)
        }
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
        self.viewModel.loginSuccess = { [weak self] in
            guard let self = self else { return }
            self.goToHome()
        }
    }

    private func onFailed() {
        let errorHandler: (String) -> Void = { [weak self] message in
            guard let self = self else { return }

            DispatchQueue.main.async {
                Loader.shared.hideLoader()
                self.showAlertAndClearText(message: message)
            }
        }

        self.viewModel.loginFailure = errorHandler
        self.viewModel.noRefreshTokenFound = {
            errorHandler(Constants.Keys.errorNoRefreshTokenFound.localized())
        }
    }

    private func onDidDisappear() {
        self.logoIconImage.transform = CGAffineTransform.identity
        self.clearTextField()
    }

}

// MARK: UserInterfaceSetup

extension LoginViewController:UserInterfaceSetup {

    // MARK: Internal

    func setupUI() {
        self.setupNotificationObservers()
        self.stackView.isHidden = true
        self.stackView.alpha = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.animateAndResizeImage()
            self.blurBackgroundImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                self.prepareAutoLogin()
            }
        }

        self.textFieldBackgroundView.forEach { view in
            view.applyThemeView(background: self.theme.textfieldBackgroundColor, radius: Constants.Radius.cornerRadiusCard)
            let blurredEffectView = self.createBlurredEffectView(
                withStyle: .light,
                for: view.bounds,
                cornerRadius: Constants.Radius.cornerRadiusCard)
            view.addSubview(blurredEffectView)
        }

        self.configurePasswordTextField()
        self.configureEmailTextField()
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

    private func configurePasswordTextField() {
        self.passwordTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.Keys.passwordTF.localized(),
            attributes: [NSAttributedString.Key.foregroundColor: self.theme.placeholderLabelColor])
        self.passwordTextField.isSecureTextEntry = true
        self.passwordTextField.accessibilityIdentifier = Constants.AccessibilityID.passwordLoginTextField
    }

    private func configureEmailTextField() {
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.Keys.emailTF.localized(),
            attributes: [NSAttributedString.Key.foregroundColor: self.theme.placeholderLabelColor])
        self.emailTextField.accessibilityIdentifier = Constants.AccessibilityID.emailLoginTextField
    }

    private func createBlurredEffectView(
        withStyle style: UIBlurEffect.Style,
        for bounds: CGRect,
        cornerRadius: CGFloat = 0)
        -> UIVisualEffectView
    {
        let blurEffect = UIBlurEffect(style: style)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.frame = bounds
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurredEffectView.alpha = 1
        blurredEffectView.clipsToBounds = true

        if cornerRadius > 0 {
            blurredEffectView.layer.cornerRadius = cornerRadius
        }

        return blurredEffectView
    }

    private func blurBackgroundImage() {
        let blurredEffectView = self.createBlurredEffectView(withStyle: .dark, for: self.backgroundImageView.bounds)
        self.backgroundImageView.addSubview(blurredEffectView)

        UIView.animate(withDuration: 1.0) {
            blurredEffectView.alpha = 1
        }
    }

    private func prepareAutoLogin() {
        if AppUtility.shared.checkTokenExist() {
            Loader.shared.showLoader(view: self.view)
            TokenRefresher.shared.refreshToken()
        } else {
            UIView.animate(withDuration: 1.0) {
                self.stackView.isHidden = false
                self.stackView.alpha = 1
            }
        }
    }

    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refresherTokenSuccess),
            name: .refresherTokenOnSuccessAutoLogin,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.refreshTokenFailure),
            name: .refresherTokenOnFailureAutoLogin,
            object: nil)
    }

}


// MARK: ApplyTheme

extension LoginViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeBackgroundTextField()
        self.applyThemeSubmitButton()
        self.applyThemeForgetButton()
    }

    // MARK: Private

    private func applyThemeBackgroundTextField() {
        self.passwordTextField.applyThemeTextField()
        self.emailTextField.applyThemeTextField()
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

