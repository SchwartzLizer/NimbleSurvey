//
//  NotificationViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class NotificationViewController: UIViewController {

    // MARK: Lifecycle

    required init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: NotificationViewController.identifier, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.applyTheme()
        self.setupUI()
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: Private

    private var viewModel: NotificationViewModel
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()

}

// MARK: UserInterfaceSetup

extension NotificationViewController: UserInterfaceSetup {

    // MARK: Internal

    internal func setupUI() {
        self.setUpView()
    }

    // MARK: Private

    private func setUpView() {
        self.titleLabel.text = self.viewModel.model.title
        self.subtitleLabel.text = self.viewModel.model.message
        self.imageView.image = UIImage(named: self.viewModel.model.image ?? "")
    }

}

// MARK: ApplyTheme

extension NotificationViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeView()
        self.applyThemeLabel()
    }

    // MARK: Private

    private func applyThemeView() {
        self.view.backgroundColor = .clear
    }

    private func applyThemeLabel() {
        self.titleLabel.applyThemeLabel(font: self.font.titleNotificationFontSize, color: self.theme.textLabelColor)
        self.subtitleLabel.applyThemeLabel(font: self.font.subtitleNotificationFontSize, color: self.theme.textLabelColor)
    }
}
