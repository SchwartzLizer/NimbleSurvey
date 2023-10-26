//
//  RightMenuViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class RightMenuViewController: UIViewController {


    // MARK: Lifecycle

    required init(viewModel: RightMenuViewModel) {
        self.viewModel = viewModel
        super.init(nibName: RightMenuViewController.identifier, bundle: nil)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Private

    private var viewModel: RightMenuViewModel

}
