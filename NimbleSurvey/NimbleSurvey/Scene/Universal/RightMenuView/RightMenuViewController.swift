//
//  RightMenuViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class RightMenuViewController: UIViewController {


    // MARK: Lifecycle

    required init(viewModel: RightMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: RightMenuViewController.identifier, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        self.onInitialized()
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    @IBOutlet weak var logoutButtonView: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!

    // MARK: Private

    private var viewModel: RightMenuViewModel
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()

}

// MARK: Action

extension RightMenuViewController: Action {
    @IBAction
    func didSelectProfile(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction
    func didSelectLogout(_: UIButton) {
        self.viewModel.requestLogout()
    }
}

// MARK: Updated

extension RightMenuViewController: Updated {

    // MARK: Internal

    func onInitialized() {
        self.onUpdated()
        self.onLogoutSuccess()
        self.onLogoutFailed()
    }

    // MARK: Private

    private func onUpdated() {
        guard let url = URL(string: self.viewModel.RightMenuModel.profileImage) else { return }
        self.profileImageView.setProfileFromURL(url: url)
        self.profileLabel.text = self.viewModel.RightMenuModel.name
        guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else { return }
        guard let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else { return }
        self.versionLabel.text = "v\(version) (\(build))"
    }

    private func onLogoutSuccess() {
        self.viewModel.onLogoutSuccess = { [weak self] in
            guard let self = self else { return }
            TokenRefresher.shared.stopTimer()
            AppUtility().loginScene()
        }
    }

    private func onLogoutFailed() {
        self.viewModel.onLogoutFailed = { message in
            AlertUtility.showAlert(title: "Error", message: message)
        }
    }
}

// MARK: ApplyTheme

extension RightMenuViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeBackground()
        self.applyThemeDivider()
        self.applyThemeLogout()
        self.applyThemeLabel()
    }

    // MARK: Private

    private func applyThemeBackground() {
        self.view.backgroundColor = self.theme.backgroundRightMenuColor
    }

    private func applyThemeDivider() {
        self.dividerLine.backgroundColor = self.theme.dividerLineColor
    }

    private func applyThemeLogout() {
        self.logoutButtonView.applyThemeButton(
            text: Constants.Keys.logoutBTN,
            font: self.font.logoutFontSize,
            color: self.theme.logoutTextColor)
    }

    private func applyThemeLabel() {
        self.profileLabel.applyThemeLabel(font: self.font.surveyTodayFontSize, color: self.theme.textLabelColor)
        self.versionLabel.applyThemeLabel(font: self.font.versionFontSize, color: self.theme.versionTextColor)
    }

}

