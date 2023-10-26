//
//  NotificationViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

final class NotificationViewModel: ViewModel {

    // MARK: Lifecycle

    init(model: NotificationModel) {
        self.model = model
    }

    // MARK: Public

    public var model: NotificationModel
}
