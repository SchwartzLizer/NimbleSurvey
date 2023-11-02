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

    func loadSurveyList() -> [SurveyListModelData]? {
        do {
            return try defaults.getObject(forKey: Constants.UserDefaultKey.surveyListKey, castTo: [SurveyListModelData].self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func removeSurveyList() {
        defaults.removeObject(forKey: Constants.UserDefaultKey.surveyListKey)
    }

    func saveProfile(data: UserProfileAttributes) {
        do {
            try defaults.setObject(data, forKey: Constants.UserDefaultKey.profileKey)
        } catch {
            print(error.localizedDescription)
        }
    }

    func loadProfile() -> UserProfileAttributes? {
        do {
            return try defaults.getObject(forKey: Constants.UserDefaultKey.profileKey, castTo: UserProfileAttributes.self)
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }

    func removeProfile() {
        defaults.removeObject(forKey: Constants.UserDefaultKey.profileKey)
    }

}

// MARK: - Constants.UserDefaultKey

extension Constants {
    enum UserDefaultKey {
        static let surveyListKey = "SurveyListKey"
        static let profileKey = "ProfileKey"
    }
}
