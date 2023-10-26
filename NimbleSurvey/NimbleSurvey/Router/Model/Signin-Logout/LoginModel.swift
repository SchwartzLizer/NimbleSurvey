//
//  LoginModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - LoginModel

struct LoginModel: Codable {
    let data: LoginData?
}

// MARK: - LoginData

struct LoginData: Codable {
    let id, type: String?
    let attributes: LoginAttributes?
}

// MARK: - LoginAttributes

struct LoginAttributes: Codable {
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
