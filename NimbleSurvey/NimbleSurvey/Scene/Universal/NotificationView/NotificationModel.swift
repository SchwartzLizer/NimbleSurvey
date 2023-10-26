//
//  NotificationModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

struct NotificationModel {

    init(title: String? = nil, message: String? = nil, image: String? = nil) {
        self.title = title
        self.message = message
        self.image = image
    }

    var title: String?
    var message: String?
    var image: String?
}
