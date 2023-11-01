//
//  StyleSheets.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - Constants.Radius

extension Constants {
    enum Radius {
        static let cornerRadiusCard: CGFloat = 12.0
    }
}

// MARK: - Theme

enum Theme: Int {
    case main

    // MARK: Internal

    var textfieldBackgroundColor: UIColor {
        switch self {
        case .main:
            return .clear
        }
    }

    var buttonBackgroundColor: UIColor {
        switch self {
        case .main:
            return UIColor().hex("#ffffff")
        }
    }

    var buttonTextColor: UIColor {
        switch self {
        case .main : return UIColor().hex("#15151A")
        }
    }

    var forgotTextColor: UIColor {
        switch self {
        case .main: return UIColor().hex("9d9b9b")
        }
    }

    var textLabelColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#ffffff")
        }
    }

    var placeholderLabelColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#9d9b9b")
        }
    }

    var textfieldLabelColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#ffffff")
        }
    }

    var backgroundRightMenuColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#212323")
        }
    }

    var dividerLineColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#4c4c4c")
        }
    }

    var logoutTextColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#9d9b9b")
        }
    }

    var versionTextColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#9d9b9b")
        }
    }

    var emptyCellBackgroundColor: UIColor {
        switch self {
        case .main: return UIColor().hex("#0f0f13")
        }
    }
}


// MARK: - Fonts

enum Fonts: Int {

    case main

    // MARK: Internal

    var buttonFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.bold, size: 17.00)!
        }
    }

    var forgotFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 14.00)!
        }
    }

    var textLabelFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 17.00)!
        }
    }

    var titleNotificationFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.bold, size: 15.00)!
        }
    }

    var subtitleNotificationFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 13.00)!
        }
    }

    var surveyTitleFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.bold, size: 28.00)!
        }
    }

    var surveySubtitleFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 17.00)!
        }
    }

    var surveyDateFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.bold, size: 13.00)!
        }
    }

    var surveyTodayFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.bold, size: 34.00)!
        }
    }

    var logoutFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 25.00)!
        }
    }

    var versionFontSize: UIFont {
        switch self {
        case .main:
            return UIFont(name: Constants.Font.regular, size: 13.00)!
        }
    }

}

// MARK: - Height

enum Height: CGFloat {
    case header = 30.0
}
