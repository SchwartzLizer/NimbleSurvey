//
//  UserProfileModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - UserProfileModel

struct UserProfileModel: Codable {
    let data: UserProfileData?
}

// MARK: - UserProfileData

struct UserProfileData: Codable {
    let id, type: String?
    let attributes: UserProfileAttributes?
}

// MARK: - UserProfileAttributes

struct UserProfileAttributes: Codable {
    let email, name: String?
    let avatarURL: String?

    init(email: String?, name: String?, avatarURL: String?) {
        self.email = email
        self.name = name
        self.avatarURL = avatarURL
    }

    enum CodingKeys: String, CodingKey {
        case email, name
        case avatarURL = "avatar_url"
    }
}

