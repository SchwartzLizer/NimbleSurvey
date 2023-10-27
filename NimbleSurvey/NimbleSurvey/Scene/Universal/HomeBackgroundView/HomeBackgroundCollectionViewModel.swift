//
//  HomeBackgroundViewModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

class HomeBackgroundCollectionViewModel: ViewModel {

    init(url: URL) {
        self.url = url
    }

    public let url: URL
}
