//
//  HomeViewController.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit
import SkeletonView
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
        if self.backgroundCollectionView.numberOfItems(inSection: 0) > 0 {
            let firstItemIndexPath = IndexPath(item: 0, section: 0)
            self.backgroundCollectionView.scrollToItem(at: firstItemIndexPath, at: .left, animated: true)
        }
        self.viewModel.clearData()
        self.backgroundCollectionView.reloadData()
        self.viewModel.pullToRefresh()
    }

}

// MARK: Updated

extension HomeViewController: Updated {

    // MARK: Internal

    internal func onInitialized() {
        self.onUpdated()
        self.onScrollUpdated()
    }

    // MARK: Private

    private func onUpdated() {
        self.viewModel.onUpdated = { [weak self] in
            guard let self = self else { return }
            self.backgroundCollectionView.reloadData()
            self.hideSkeletonView()
            self.pageControl.numberOfPages = self.viewModel.datas.count
            self.pageControl.currentPage = 0
            self.pageControl.translatesAutoresizingMaskIntoConstraints = false
            self.pageControlView.addSubview(self.pageControl)
            let leadingConstraint = NSLayoutConstraint(
                item: pageControl,
                attribute: .leading,
                relatedBy: .equal,
                toItem: pageControlView,
                attribute: .leading,
                multiplier: 1,
                constant: 0) // Adjust constant value for left margin

            // Center pageControl vertically within pageControlView
            let centerYConstraint = NSLayoutConstraint(
                item: pageControl,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: pageControlView,
                attribute: .centerY,
                multiplier: 1,
                constant: 0)

            self.pageControlView.addConstraints([leadingConstraint, centerYConstraint])
            self.todayLabel.text = Constants.Keys.todaySurvey.localized()

            guard
                let title = self.viewModel.lists.first?.title,
                let subTitle = self.viewModel.lists.first?.subTitle
            else { return }
            self.titleLabel.text = title
            self.subTitleLabel.text = subTitle

            self.dateLabel.text = self.viewModel.processDate()
            guard let avatarPath = self.viewModel.profileData.avatarURL else { return }
            guard let avatarURL = URL(string: avatarPath) else { return }
            self.profileImageView.setProfileFromURL(url: avatarURL)
            self.enterSurveyButton.setImage(UIImage(named: Constants.Assest.action), for: .normal)
            self.profileButtonView.isUserInteractionEnabled = true

            if self.menu == nil {
                guard let name = self.viewModel.profileData.name else { return }
                guard let profileURL = self.viewModel.profileData.avatarURL else { return }
                let rightMenuModel = RightMenuModel(name: name, profileImage: profileURL)
                let rightMenuViewModel = RightMenuViewModel(model: rightMenuModel)
                let rightMenuVC = RightMenuViewController(viewModel: rightMenuViewModel)
                self.menu = SideMenuNavigationController(rootViewController: rightMenuVC)
                self.menu?.presentationStyle = .menuSlideIn
            }
            self.isRefreshing = false
        }
    }

    private func onScrollUpdated() {
        self.viewModel.onScrollUpdated = { [weak self] data in
            guard let self = self else { return }
            self.titleLabel.text = data.title
            self.subTitleLabel.text = data.subTitle
        }
    }

    private func showSkeletonView() {
        self.titleLabel.showGradientSkeleton()
        self.subTitleLabel.showAnimatedGradientSkeleton()
        self.todayLabel.showAnimatedGradientSkeleton()
        self.dateLabel.showAnimatedGradientSkeleton()
        self.profileImageView.showAnimatedGradientSkeleton()
        self.enterSurveyButton.showAnimatedGradientSkeleton()
        self.pageControlView.showAnimatedGradientSkeleton()
    }

    private func hideSkeletonView() {
        self.titleLabel.hideSkeleton()
        self.subTitleLabel.hideSkeleton()
        self.todayLabel.hideSkeleton()
        self.dateLabel.hideSkeleton()
        self.profileImageView.hideSkeleton()
        self.enterSurveyButton.hideSkeleton()
        self.pageControlView.hideSkeleton()
    }
}

// MARK: ApplyTheme

extension HomeViewController: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeLabel()
    }

    // MARK: Private

    private func applyThemeLabel() {
        self.titleLabel.applyThemeLabel(font: self.font.surveyTitleFontSize, color: self.theme.textLabelColor)
        self.subTitleLabel.applyThemeLabel(font: self.font.surveySubtitleFontSize, color: self.theme.textLabelColor)
        self.todayLabel.applyThemeLabel(font: self.font.surveyTodayFontSize, color: self.theme.textLabelColor)
        self.dateLabel.applyThemeLabel(font: self.font.surveyDateFontSize, color: self.theme.textLabelColor)
    }


}
