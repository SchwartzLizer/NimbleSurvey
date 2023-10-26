//
//  RightMenuModel.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - RightMenuViewModel

final class RightMenuViewModel: ViewModel {

    // MARK: Lifecycle

    init(model: RightMenuModel) {
        self.RightMenuModel = model
    }

    // MARK: Internal

    var RightMenuModel: RightMenuModel

}
