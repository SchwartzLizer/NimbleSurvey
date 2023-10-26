//
//  RefreshTokenModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - RefreshTokenModel

struct RefreshTokenModel: Codable {
    let data: RefreshTokenData?
}

// MARK: - RefreshTokenData

struct RefreshTokenData: Codable {
    let id, type: String?
    let attributes: RefreshTokenAttributes?
}

// MARK: - RefreshTokenAttributes

struct RefreshTokenAttributes: Codable {
    let accessToken, tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let createdAt: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case createdAt = "created_at"
    }
}
