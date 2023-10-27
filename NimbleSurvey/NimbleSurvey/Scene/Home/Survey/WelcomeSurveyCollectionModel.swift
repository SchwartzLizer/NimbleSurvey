//
//  WelcomeSurveyCollectionModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

struct WelcomeSurveyCollectionModel {

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    let title:String
    let description:String
}
