//
//  UserDefault.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

let defaults = UserDefaults.standard

// MARK: - UserDefault

class UserDefault {

    func saveSurveyList(data: [SurveyListModelData]) {
        do {
            try defaults.setObject(data, forKey: Constants.UserDefaultKey.surveyListKey)
        } catch {
            print(error.localizedDescription)
        }
    }

    func getSurveyList() -> [SurveyListModelData]? {
        do {
            return try defaults.getObject(forKey: Constants.UserDefaultKey.surveyListKey, castTo: [SurveyListModelData].self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

}

// MARK: - Constants.UserDefaultKey

extension Constants {
    enum UserDefaultKey {
        static let refreshTokenKey = "RefreshTokenKey"
        static let accessTokenKey = "AccessTokenKey"
        static let surveyListKey = "SurveyListKey"
    }
}
