//
//  ButtonPresets.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UIButton {
    func applyThemeButton(
        text: String,
        font Font: UIFont,
        color Color: UIColor,
        round roundCorner: Double = 0,
        backgroundColor BackgroundColor: UIColor = .clear,
        borderColor BorderColor: UIColor = .clear)
    {
        self.setTitle(text.localized(), for: .normal)
        self.titleLabel?.font = Font
        self.setTitleColor(Color, for: .normal)
        self.layer.cornerRadius = roundCorner
        self.backgroundColor = BackgroundColor
        self.layer.borderColor = BorderColor.cgColor
        self.layer.borderWidth = 1
    }

}
