//
//  RouterEnumeration.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - ErrorType

enum ErrorType: LocalizedError {
    case parseUrlFail
    case notFound
    case validationError
    case serverError
    case defaultError

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case .parseUrlFail:
            return "Cannot initial URL object."
        case .notFound:
            return "Not Found"
        case .validationError:
            return "Validation Errors"
        case .serverError:
            return "Internal Server Error"
        case .defaultError:
            return "Something went wrong."
        }
    }
}

// MARK: - Result

enum Result<T> {
    case success(data: T)
    case failure(error: Error)
}

enum GrantType: String {
    case password = "password"
    case refreshToken = "refresh_token"
}


