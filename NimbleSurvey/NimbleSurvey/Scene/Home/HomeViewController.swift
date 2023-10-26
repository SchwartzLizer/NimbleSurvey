//
//  HomeViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: Lifecycle

    required init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: HomeViewController.identifier, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    var viewModel: HomeViewModel


}
