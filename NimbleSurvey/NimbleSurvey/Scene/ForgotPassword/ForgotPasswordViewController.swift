//
//  ForgotPasswordViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    // MARK: Lifecycle

    required init(viewModel: ForgotPasswordViewModel) {
        self.ViewModel = viewModel
        super.init(nibName: ForgotPasswordViewController.identifier, bundle: nil)
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

    // MARK: Private

    private var ViewModel: ForgotPasswordViewModel

}
