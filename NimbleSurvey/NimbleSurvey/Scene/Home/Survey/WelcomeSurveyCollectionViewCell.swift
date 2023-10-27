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
    }

    // MARK: Public

    public var viewModel: WelcomeSurveyCollectionViewCell?

    // MARK: Internal

    @IBOutlet weak var startSuveyButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var backButtonView: UIButton!

    // MARK: Private

    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()

}

// MARK: ApplyTheme

extension WelcomeSurveyCollectionViewCell: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeLabel()
    }

    // MARK: Private

    private func applyThemeLabel() {
        self.titleLabel.applyThemeLabel(font: self.font.surveyTitleFontSize, color: self.theme.textLabelColor)
        self.subtitleLabel.applyThemeLabel(font: self.font.surveySubtitleFontSize, color: self.theme.textLabelColor)
    }


}

