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

    func saveRefreshToken(data: String) {
        defaults.set(data, forKey: Constants.UserDefaultKey.refreshTokenKey)
    }

    func getRefreshToken() -> String? {
        return defaults.string(forKey: Constants.UserDefaultKey.refreshTokenKey)
    }

    func saveAccessToken(data: String) {
        defaults.set(data, forKey: Constants.UserDefaultKey.accessTokenKey)
    }

    func getAccessToken() -> String? {
        return defaults.string(forKey: Constants.UserDefaultKey.accessTokenKey)
    }

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

// MARK: - ObjectSavable

protocol ObjectSavable {
    func setObject<Object>(_ object: Object, forKey: String) throws where Object: Encodable
    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable
}


// MARK: - UserDefaults + ObjectSavable

extension UserDefaults: ObjectSavable {
    func setObject(_ object: some Encodable, forKey: String) throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(object)
            set(data, forKey: forKey)
        }
        catch {
            throw ObjectSavableError.unableToEncode
        }
    }

    func getObject<Object>(forKey: String, castTo type: Object.Type) throws -> Object where Object: Decodable {
        guard let data = data(forKey: forKey) else { throw ObjectSavableError.noValue }
        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(type, from: data)
            return object
        }
        catch {
            throw ObjectSavableError.unableToDecode
        }
    }
}

// MARK: - ObjectSavableError

enum ObjectSavableError: String, LocalizedError {
    case unableToEncode = "Unable to encode object into data"
    case noValue = "No data object found for the given key"
    case unableToDecode = "Unable to decode object into given type"

    var errorDescription: String? {
        rawValue
    }
}
