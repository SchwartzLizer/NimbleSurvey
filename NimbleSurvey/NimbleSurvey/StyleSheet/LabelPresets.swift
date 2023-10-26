//
//  LabelPresets.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UILabel {
    func applyThemeLabel(font: UIFont,color: UIColor,fitWidth: Bool = false) {
        self.text = self.text
        self.font = font
        self.textColor = color
        if fitWidth {
            self.adjustsFontSizeToFitWidth = true
            self.minimumScaleFactor = 0.5
        }
    }
}
