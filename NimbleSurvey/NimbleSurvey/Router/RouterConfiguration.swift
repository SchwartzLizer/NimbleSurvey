//
//  RouterConfiguration.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

class RouterConfiguration {

    // MARK: Public

    public static let surveyAPI: String = {
        if let url = RouterConfiguration.getConfig().object(forKey: "SurveyAPI") as? String {
            return url
        } else {
            Logger.print("Error: base_url not found in Configuration.")
            return "https://default-url.com"
        }
    }()

    // MARK: Private

    private static func getConfig() -> NSDictionary {
        if
            let env = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String,
            let path = Bundle.main.path(forResource: "RouterBasePath", ofType: "plist"),
            let configFile = NSDictionary(contentsOfFile: path),
            let config = configFile[env] as? NSDictionary
        {
            return config
        } else {
            Logger.print("Error: Configuration not found.")
            return NSDictionary()
        }
    }
}


