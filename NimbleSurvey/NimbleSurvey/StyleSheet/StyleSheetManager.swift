//
//  StyleSheetManager.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UIColor {
    func hex(_ hex: String) -> UIColor {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        guard cString.count == 6, let rgbValue = UInt32(cString, radix: 16) else {
            return UIColor.gray
        }

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0)
    }
}

// Enum declaration
let SelectedThemeKey = "Main"
let SelectedFontKey = "Main"

// MARK: - StyleSheetManager

// This will let you use a theme in the app.
enum StyleSheetManager {

    // ThemeManager
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .main
        }
    }

    static func currentFontTheme() -> Fonts {
        if
            let storedFontThemeValue = UserDefaults.standard.value(forKey: SelectedFontKey) as? Int,
            let storedFontTheme = Fonts(rawValue: storedFontThemeValue)
        {
            return storedFontTheme
        } else {
            return .main
        }
    }

    static func applyTheme(theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
    }

}
