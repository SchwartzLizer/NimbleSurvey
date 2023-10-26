//
//  LoginViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

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

