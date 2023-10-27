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
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    @IBOutlet weak var logoutButtonView: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dividerLine: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!

    // MARK: Private

    private var viewModel: RightMenuViewModel
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()

}

// MARK: Action

extension RightMenuViewController: Action {
    @IBAction
    func didSelectProfile(_: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction
    func didSelectLogout(_: UIButton) {
        self.viewModel.requestLogout()
    }
}
