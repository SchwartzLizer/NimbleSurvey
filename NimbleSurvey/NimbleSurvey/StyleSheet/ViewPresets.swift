//
//  ViewPresets.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UIView {
    func applyThemeView(background: UIColor, radius: CGFloat) {
        self.backgroundColor = background
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = radius
    }
}
