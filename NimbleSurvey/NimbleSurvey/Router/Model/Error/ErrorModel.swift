//
//  ErrorModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

struct ErrorResponse: Decodable {
    struct Error: Decodable {
        let source: String?
        let detail: String?
        let code: String?
    }

    let errors: [Error]
}
