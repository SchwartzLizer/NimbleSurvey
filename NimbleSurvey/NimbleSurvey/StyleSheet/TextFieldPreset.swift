//
//  TextFieldPreset.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UITextField {
    func applyThemeTextField() {
        let theme = StyleSheetManager.currentTheme()
        let font = StyleSheetManager.currentFontTheme()
        self.borderStyle = .none
        self.font = font.textLabelFontSize
        self.textColor = theme.textfieldLabelColor
    }
}
