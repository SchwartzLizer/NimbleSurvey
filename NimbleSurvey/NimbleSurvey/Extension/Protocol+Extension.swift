//
//  Protocol+Extension.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

// MARK: - Updated

// View
protocol Updated {
    func onInitialized()
}

// MARK: - UserInterfaceSetup

protocol UserInterfaceSetup {
    func setupUI()
}

// MARK: - Action

protocol Action { }

// MARK: - ApplyTheme

protocol ApplyTheme {
    func applyTheme()
}

// MARK: - ViewModel

// ViewModel
protocol ViewModel { }

// MARK: - RequestService

protocol RequestService { }

// MARK: - ProcessDataSource

protocol ProcessDataSource { }

// MARK: - Logic

protocol Logic { }
