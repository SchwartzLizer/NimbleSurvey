//
//  ForgotPasswordModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - ForgotPassword

struct ForgotPassword: Codable {
    let meta: ForgotPasswordData?
}

// MARK: - ForgotPasswordData

struct ForgotPasswordData: Codable {
    let message: String?
}
