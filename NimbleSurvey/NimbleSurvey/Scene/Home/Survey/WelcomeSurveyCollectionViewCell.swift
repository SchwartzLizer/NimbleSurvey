//
//  WelcomeSurveyCollectionViewCell.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - WelcomeSurveyCollectionViewCell

class WelcomeSurveyCollectionViewCell: UICollectionViewCell {

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyTheme()
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    public var viewModel: WelcomeSurveyCollectionViewModel? {
        didSet {
            self.onInitialized()
        }
    }

    // MARK: Internal

    @IBOutlet weak var startSuveyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backButtonView: UIButton!

    // MARK: Private

    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()


}

// MARK: Action

extension WelcomeSurveyCollectionViewCell: Action {
    @IBAction
    func didSelectBack(_: UIButton) {
        NotificationCenter.default.post(name: .backSurvey, object: nil)
    }
}

// MARK: Updated

extension WelcomeSurveyCollectionViewCell: Updated {
    func onInitialized() {
        self.onUpdated()
    }

    func onUpdated() {
        guard let viewModel = self.viewModel else { return }
        self.titleLabel.text = viewModel.model.title
        self.subtitleLabel.text = viewModel.model.description
    }
}

// MARK: ApplyTheme

extension WelcomeSurveyCollectionViewCell: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeLabel()
        self.applyThemeStartSurveyButton()
        self.applyThemeBackButton()
    }

    // MARK: Private

    private func applyThemeLabel() {
        self.titleLabel.applyThemeLabel(font: self.font.surveyTitleFontSize, color: self.theme.textLabelColor)
        self.subtitleLabel.applyThemeLabel(font: self.font.surveySubtitleFontSize, color: self.theme.textLabelColor)
    }

    private func applyThemeStartSurveyButton() {
        self.startSuveyButton.applyThemeButton(
            text: Constants.Keys.startSurveyBTN,
            font: self.font.buttonFontSize,
            color: self.theme.buttonTextColor,
            round: Constants.Radius.cornerRadiusCard,
            backgroundColor: self.theme.buttonBackgroundColor,
            borderColor: self.theme.buttonBackgroundColor)
    }

    private func applyThemeBackButton() {
        let backImage = UIImage(named: Constants.Assest.back)
        self.backButtonView.setImage(backImage, for: .normal)
    }


}

