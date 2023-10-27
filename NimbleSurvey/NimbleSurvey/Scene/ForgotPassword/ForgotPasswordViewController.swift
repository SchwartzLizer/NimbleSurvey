//
//  ForgotPasswordViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - ForgotPasswordViewController

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
        self.applyTheme()
        self.setupUI()
        self.onInitialized()
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.emailTextField.text = ""
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

// MARK: Action

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

// MARK: Updated

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

// MARK: UserInterfaceSetup

extension ForgotPasswordViewController: UserInterfaceSetup {

    // MARK: Internal

    internal func setupUI() {
        self.setupNotificationView()
    }

    // MARK: Private

    private func setupNotificationView() {
        // Initialize the view and off-screen positioning
        self.navbar = UIApplication.shared.statusBarFrame.height
        let yPosition = UIApplication.shared.statusBarFrame.height + 62
        self.notificationView = UIView(frame: CGRect(
            x: 0,
            y: -abs(yPosition),
            width: self.view.frame.size.width,
            height: yPosition))
        self.notificationView.backgroundColor = .clear

        // BlurView
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.clipsToBounds = true
        blurredEffectView.frame = self.notificationView.bounds
        self.notificationView.addSubview(blurredEffectView)

        // NotificationView
        let view = UIView(frame: CGRect(x: 0, y: 60, width: self.view.frame.size.width, height: 56))
        let notificationModel = NotificationModel(
            title: Constants.Keys.notificationResetEmailTitle.localized(),
            message: Constants.Keys.notificationResetEmailMessage.localized(),
            image: Constants.Assest.notification.localized())
        let notificationVC = NotificationViewController(viewModel: NotificationViewModel(model: notificationModel))
        view.addSubview(notificationVC.view)
        notificationVC.view.frame = view.bounds
        self.notificationView.addSubview(view)

        self.navigationController?.view.addSubview(self.notificationView)
    }

}


extension ForgotPasswordViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.blurBackgroundImage()
        self.applyThemeBackgroundTextField()
        self.applyThemeResetButton()
        self.applyThemeTitleLabel()
        self.applyThemeNavbar()
    }

    // MARK: Private

    private func blurBackgroundImage() {
        // Create the effect and effect view.
        let blurEffect = UIBlurEffect(style: .dark) // The style determines the maximum intensity.
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.backgroundImageView.bounds
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.backgroundImageView.addSubview(blurredEffectView)
    }

    private func applyThemeBackgroundTextField() {
        self.textFieldBackgroundView.applyThemeView(
            background: self.theme.textfieldBackgroundColor,
            radius: Constants.Radius.cornerRadiusCard)
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurredEffectView.layer.cornerRadius = Constants.Radius.cornerRadiusCard
        blurredEffectView.clipsToBounds = true
        blurredEffectView.frame = self.textFieldBackgroundView.bounds
        self.textFieldBackgroundView.addSubview(blurredEffectView)
        self.emailTextField.borderStyle = .none
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: Constants.Keys.emailTF.localized(),
            attributes: [NSAttributedString.Key.foregroundColor: self.theme.placeholderLabelColor])
        self.emailTextField.font = self.font.textLabelFontSize
        self.emailTextField.textColor = theme.textfieldLabelColor
    }

    private func applyThemeResetButton() {
        self.resetButtonView.applyThemeButton(
            text: Constants.Keys.resetBTN,
            font: self.font.buttonFontSize,
            color: self.theme.buttonTextColor,
            round: Constants.Radius.cornerRadiusCard,
            backgroundColor: self.theme.buttonBackgroundColor,
            borderColor: self.theme.buttonBackgroundColor)
    }

    private func applyThemeTitleLabel() {
        self.titleLabel.text = Constants.Keys.resetPasswordDescription.localized()
        self.titleLabel.applyThemeLabel(font: self.font.textLabelFontSize, color: self.theme.textLabelColor)
    }

    private func applyThemeNavbar() {
        let backButton = UIButton(type: .custom)
        let backImage = UIImage(named: "Back")
        backButton.setImage(backImage, for: .normal)
        backButton.addTarget(self, action: #selector(self.backAction(_:)), for: .touchUpInside)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
}
