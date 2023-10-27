//
//  HomeModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - HomeModel

struct HomeModel: Codable {
    let data: [HomeDataModel]?

    init(data: [HomeDataModel]?) {
        self.data = data
    }
}

// MARK: - HomeDataModel

struct HomeDataModel: Codable, Equatable {
    let title: String?
    let subTitle: String?

    init(title: String?, subTitle: String?) {
        self.title = title
        self.subTitle = subTitle
    }
}

