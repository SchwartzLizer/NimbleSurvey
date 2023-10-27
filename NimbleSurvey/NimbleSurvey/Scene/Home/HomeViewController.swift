//
//  HomeViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit
import SideMenu

// MARK: - HomeViewController

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

    @IBOutlet weak var enterSurveyButton: UIButton!
    @IBOutlet weak var pageControlView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var backgroundCollectionView: UICollectionView!
    @IBOutlet weak var surveyCollectionView: UICollectionView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileButtonView: UIButton!

    // MARK: Private

    private var pageControl = CustomPageControl()
    private var viewModel: HomeViewModel
    private var isRefreshing = false
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()
    private var menu: SideMenuNavigationController?

    private var cellList: [(identifier: String, nib: UINib)] {
        return [
            (
                identifier: HomeBackgroundViewController.identifier,
                nib: HomeBackgroundViewController.nib),
        ]
    }

}

// MARK: Action

extension HomeViewController: Action {
    @IBAction
    func didSelectProfile(_: UIButton) {
        guard let menu = self.menu else { return }
        present(menu, animated: true, completion: nil)
    }

    @objc
    func handlePullToRefreshNotification(_: Notification) {
        self.isRefreshing = true
        self.showSkeletonView()
        if self.collectionView.numberOfItems(inSection: 0) > 0 {
            let firstItemIndexPath = IndexPath(item: 0, section: 0)
            self.collectionView.scrollToItem(at: firstItemIndexPath, at: .left, animated: true)
        }
        self.viewModel.clearData()
        self.collectionView.reloadData()
        self.viewModel.pullToRefresh()
    }

}
