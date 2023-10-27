//
//  NotificationViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class NotificationViewController: UIViewController {

    // MARK: Lifecycle

    required init(viewModel: NotificationViewModel) {
        self.viewModel = viewModel
        super.init(nibName: NotificationViewController.identifier, bundle: nil)
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

    // MARK: Internal

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!

    // MARK: Private

    private var viewModel: NotificationViewModel
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()


}
