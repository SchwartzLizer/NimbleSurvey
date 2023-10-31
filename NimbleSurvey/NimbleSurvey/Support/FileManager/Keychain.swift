//
//  Keychain.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/31/23.
//

import Foundation
import Security

// MARK: - Keychain

class Keychain {

    // MARK: Lifecycle

    init() { }

    // MARK: Internal

    static let shared = Keychain()

    func saveRefreshToken(data: String) -> String {
        guard let dataToSave = data.data(using: .utf8) else {
            print("Failed to convert string to data.")
            return "Failed to convert string to data."
        }

        let status = Keychain.save(key: Constants.KeyChainKey.refreshTokenKey, data: dataToSave)

        if status == errSecSuccess {
            print("Successfully saved refresh Token.")
            return "Successfully saved data."
        } else {
            let message = "Failed to save data with status: \(status)"
            print(message)
            return message
        }
    }

    func getRefreshToken() -> String {
        guard
            let data = Keychain.load(key: Constants.KeyChainKey.refreshTokenKey),
            let token = String(data: data, encoding: .utf8)
        else {
            print("Failed to fetch or decode refreshToken")
            return ""
        }
        return token
    }

    func saveAccessToken(data: String) -> String {
        guard let dataToSave = data.data(using: .utf8) else {
            print("Failed to convert string to data.")
            return "Failed to convert string to data."
        }

        let status = Keychain.save(key: Constants.KeyChainKey.accessTokenKey, data: dataToSave)

        if status == errSecSuccess {
            print("Successfully saved accessToken.")
            return "Successfully saved data."
        } else {
            let message = "Failed to save data with status: \(status)"
            print(message)
            return message
        }
    }

    func getAccessToken() -> String {
        guard
            let data = Keychain.load(key: Constants.KeyChainKey.accessTokenKey),
            let token = String(data: data, encoding: .utf8) else
        {
            print("Failed to fetch or decode accessToken.")
            return ""
        }
        print("Successfully fetched accessToken: \(token)")
        return token
    }

    func removeRefreshToken() -> String {
        let status = Keychain.delete(key: Constants.KeyChainKey.refreshTokenKey)
        let message = "Remove refreshToken status: \(status)"
        print(message)
        return message
    }

    func removeAccessToken() -> String {
        let status = Keychain.delete(key: Constants.KeyChainKey.accessTokenKey)
        let message = "Remove accessToken status: \(status)"
        print(message)
        return message
    }
}

// MARK: - Constants.KeyChainKey

extension Constants {
    enum KeyChainKey {
        static let refreshTokenKey = "RefreshTokenKey"
        static let accessTokenKey = "AccessTokenKey"
    }
}


extension Keychain {
    // Save data to keychain
    static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
        ] as [String: Any]

        SecItemDelete(query as CFDictionary) // Optionally clear any existing item before saving.
        return SecItemAdd(query as CFDictionary, nil)
    }

    // Load data from keychain
    static func load(key: String) -> Data? {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String : kCFBooleanTrue!,
            kSecMatchLimit as String : kSecMatchLimitOne,
        ] as [String : Any]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as? Data
        } else {
            print("Failed to fetch data from keychain with status: \(status)")
            return nil
        }
    }

    // Delete data from keychain
    static func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ] as [String : Any]

        return SecItemDelete(query as CFDictionary)
    }
}
