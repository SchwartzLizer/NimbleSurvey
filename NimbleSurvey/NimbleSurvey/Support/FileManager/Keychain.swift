//
//  Keychain.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/31/23.
//

import Foundation
import Security

class Keychain {
    // Save data to keychain
    static func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String : data,
        ] as [String : Any]

        SecItemDelete(query as CFDictionary)
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
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    // Delete data from keychain
    static func delete(key: String) -> OSStatus {
        let query = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
        ] as [String : Any]

        return SecItemDelete(query as CFDictionary)
    }
}
