//
//  NotificationCenter.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

extension Notification.Name {
    static let refreshSurvey = Notification.Name("refreshSurvey")
    static let backSurvey = Notification.Name("backSurvey")
    static let zoomInBackground = Notification.Name("zoomInBackground")
    static let zoomOutBackground = Notification.Name("zoomOutBackground")
    static let refresherTokenAppDidEnterBackground = Notification.Name("refresherTokenAppDidEnterBackground")
    static let refresherTokenAppWillEnterForeground = Notification.Name("refresherTokenAppWillEnterForeground")
}
