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
        self.applyTheme()
        self.onInitialized()
        self.setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)
        showSkeletonView()
        self.viewModel.requestData(accessToken: UserDefault().getAccessToken() ?? "")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
                identifier: HomeBackgroundCollectionViewCell.identifier,
                nib: HomeBackgroundCollectionViewCell.nib),
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

    @objc
    func handleBackSurveyNotification(_: Notification) {

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

// MARK: UserInterfaceSetup, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension HomeViewController: UserInterfaceSetup, UICollectionViewDelegate, UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{

    // MARK: Internal

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        if self.viewModel.datas.isEmpty {
            return 1
        }
        return self.viewModel.datas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if self.viewModel.datas.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCellIdentifier", for: indexPath)
            cell.backgroundColor = self.theme.emptyCellBackgroundColor
            return cell
        } else {
            guard
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: HomeBackgroundCollectionViewCell.identifier,
                    for: indexPath) as? HomeBackgroundCollectionViewCell,
                let path = self.viewModel.datas[indexPath.row].attributes?.coverImageURL,
                let url = URL(string: path + "l") // "l" for high resolution
            else {
                return UICollectionViewCell()
            }
            cell.viewModel = HomeBackgroundCollectionViewModel(url: url)
            return cell
        }
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath)
        -> CGSize
    {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    internal func setupUI() {
        self.setupCollectionView()
        self.setupSkeletonView()
        self.profileButtonView.isUserInteractionEnabled = false
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handlePullToRefreshNotification(_:)),
            name: .refreshSurvey,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handlePullToRefreshNotification(_:)),
            name: .backSurvey,
            object: nil)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isRefreshing != true {
            let pageWidth = scrollView.frame.size.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            self.pageControl.currentPage = currentPage
            _ = self.viewModel.scrollViewUpdate(page: currentPage)
        }
    }

    // MARK: Private

    private func setupCollectionView() {
        self.cellList.forEach { self.backgroundCollectionView.register($0.nib, forCellWithReuseIdentifier: $0.identifier) }
        self.backgroundCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyCellIdentifier")
        self.backgroundCollectionView.delegate = self
        self.backgroundCollectionView.dataSource = self
        if let layout = backgroundCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        self.backgroundCollectionView.isPagingEnabled = true
        if #available(iOS 11.0, *) {
            backgroundCollectionView.contentInsetAdjustmentBehavior = .never
        }
    }

    private func setupSkeletonView() {
        self.titleLabel.isSkeletonable = true
        self.subTitleLabel.isSkeletonable = true
        self.todayLabel.isSkeletonable = true
        self.dateLabel.isSkeletonable = true
        self.profileImageView.isSkeletonable = true
        self.enterSurveyButton.isSkeletonable = true
        self.pageControlView.isSkeletonable = true
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
