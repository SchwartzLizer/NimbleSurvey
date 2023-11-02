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
        self.surveyCollectionView.isHidden = true
    }

    override func viewDidAppear(_: Bool) {
        super.viewDidAppear(true)
        showSkeletonView()
        self.viewModel.requestData(accessToken: Keychain.shared.getAccessToken() )
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

    @IBOutlet weak var stackViewToday: UIStackView!
    @IBOutlet weak var stackViewTitle: UIStackView!

    // MARK: Private

    private var pageControl = CustomPageControl()
    private var viewModel: HomeViewModel
    private var isRefreshing = false
    private lazy var theme = StyleSheetManager.currentTheme()
    private lazy var font = StyleSheetManager.currentFontTheme()
    private var menu: SideMenuNavigationController?
    private var pageIndex = 0

    private var cellBackgroundList: [(identifier: String, nib: UINib)] {
        return [
            (
                identifier: HomeBackgroundCollectionViewCell.identifier,
                nib: HomeBackgroundCollectionViewCell.nib),
        ]
    }

    private var cellSurveyList: [(identifier: String, nib: UINib)] {
        return [
            (
                identifier: WelcomeSurveyCollectionViewCell.identifier,
                nib: WelcomeSurveyCollectionViewCell.nib),
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
    func handleBacktoHomeNotification(_: Notification) {
        NotificationCenter.default.post(name: .zoomOutBackground, object: nil)

        self.pageControlView.isHidden = false
        self.surveyCollectionView.isHidden = true
        self.stackViewTitle.isHidden = false
        self.stackViewToday.isHidden = false
        self.backgroundCollectionView.isUserInteractionEnabled = true
        self.surveyCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.surveyCollectionView.alpha = 0
            self.stackViewTitle.alpha = 1
            self.stackViewToday.alpha = 1
            self.pageControlView.alpha = 1
        }, completion: { _ in
        })
    }

    @IBAction
    func didSelectStartSurvey(_: UIButton) {
        NotificationCenter.default.post(name: .zoomInBackground, object: nil)
        self.surveyCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        self.surveyCollectionView.reloadData()

        UIView.animate(withDuration: 0.5, animations: {
            self.surveyCollectionView.alpha = 1
            self.stackViewTitle.alpha = 0
            self.stackViewToday.alpha = 0
            self.pageControlView.alpha = 0
        }, completion: { _ in
            self.pageControlView.isHidden = true
            self.backgroundCollectionView.isUserInteractionEnabled = false
            self.stackViewTitle.isHidden = true
            self.stackViewToday.isHidden = true
            self.surveyCollectionView.isHidden = false
        })
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
            self.hideSkeletonView()
            self.pageControlOnUpdate()
            self.labelOnUpdate()
            self.buttonOnUpdate()
            self.rightMenuOnUpdate()
            self.isRefreshing = false
        }
    }

    private func pageControlOnUpdate() {
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
            constant: 0)
        let centerYConstraint = NSLayoutConstraint(
            item: pageControl,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: pageControlView,
            attribute: .centerY,
            multiplier: 1,
            constant: 0)
        self.pageControlView.addConstraints([leadingConstraint, centerYConstraint])
    }

    private func labelOnUpdate() {
        self.todayLabel.text = Constants.Keys.todaySurvey.localized()
        guard
            let title = self.viewModel.lists.first?.title,
            let subTitle = self.viewModel.lists.first?.subTitle
        else { return }
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.dateLabel.text = self.viewModel.processDate()
    }

    private func buttonOnUpdate() {
        guard
            let avatarPath = self.viewModel.profileData.avatarURL,
            let avatarURL = URL(string: avatarPath)
        else { return }
        self.profileImageView.setProfileFromURL(url: avatarURL)
        self.profileButtonView.isUserInteractionEnabled = true
        self.backgroundCollectionView.reloadData()
        self.enterSurveyButton.setImage(UIImage(named: Constants.Assest.action), for: .normal)
    }

    private func rightMenuOnUpdate() {
        if self.menu == nil {
            guard let name = self.viewModel.profileData.name else { return }
            guard let profileURL = self.viewModel.profileData.avatarURL else { return }
            let rightMenuModel = RightMenuModel(name: name, profileImage: profileURL)
            let rightMenuViewModel = RightMenuViewModel(model: rightMenuModel)
            let rightMenuVC = RightMenuViewController(viewModel: rightMenuViewModel)
            self.menu = SideMenuNavigationController(rootViewController: rightMenuVC)
            self.menu?.presentationStyle = .menuSlideIn
        }
    }

    private func onScrollUpdated() {
        self.viewModel.onScrollUpdated = { [weak self] data in
            guard let self = self else { return }
            self.titleLabel.text = data.title
            self.subTitleLabel.text = data.subTitle
        }
    }

    private func onFailed() {
        self.viewModel.onFailed = { [weak self] message in
            AlertUtility.showAlert(title: Constants.Keys.appName.localized(), message: message) {
                self?.viewModel.pullToRefresh()
            }
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

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        switch collectionView {
        case self.backgroundCollectionView:
            if self.viewModel.datas.isEmpty {
                return 1
            }
            return self.viewModel.datas.count
        case self.surveyCollectionView:
            return 1
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case self.backgroundCollectionView:
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
        case self.surveyCollectionView:
            if self.viewModel.datas.isEmpty {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emptyCellIdentifier", for: indexPath)
                cell.backgroundColor = .clear
                return cell
            } else {
                guard
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: WelcomeSurveyCollectionViewCell.identifier,
                        for: indexPath) as? WelcomeSurveyCollectionViewCell
                else {
                    return UICollectionViewCell()
                }
                guard let title = self.viewModel.datas[self.pageIndex].attributes?.title
                else { return UICollectionViewCell() }
                guard let description = self.viewModel.datas[self.pageIndex].attributes?.description
                else { return UICollectionViewCell() }
                let model = WelcomeSurveyCollectionModel(
                    title: title,
                    description: description)
                cell.contentView.backgroundColor = .clear
                cell.backgroundColor = .clear
                cell.viewModel = WelcomeSurveyCollectionViewModel(model: model)
                return cell
            }
        default: return UICollectionViewCell()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath)
        -> CGSize
    {
        switch collectionView {
        case self.backgroundCollectionView: return CGSize(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height)
        case self.surveyCollectionView: return CGSize(
                width: self.surveyCollectionView.bounds.width,
                height: self.surveyCollectionView.bounds.height)
        default: return CGSize(width: 0, height: 0)
        }
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
            selector: #selector(self.handleBacktoHomeNotification(_:)),
            name: .backSurvey,
            object: nil)
    }


    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.isRefreshing != true {
            let pageWidth = scrollView.frame.size.width
            let currentPage = Int((scrollView.contentOffset.x + pageWidth / 2) / pageWidth)
            self.pageIndex = currentPage
            self.pageControl.currentPage = currentPage
            _ = self.viewModel.scrollViewUpdate(page: currentPage)
        }
    }

    // MARK: Private

    private func setupCollectionView() {
        self.cellBackgroundList
            .forEach { self.backgroundCollectionView.register($0.nib, forCellWithReuseIdentifier: $0.identifier) }
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

        self.cellSurveyList.forEach { self.surveyCollectionView.register($0.nib, forCellWithReuseIdentifier: $0.identifier) }
        self.surveyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emptyCellIdentifier")
        self.surveyCollectionView.delegate = self
        self.surveyCollectionView.dataSource = self
        if let layout = surveyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
        self.surveyCollectionView.backgroundColor = .clear
        self.surveyCollectionView.isPagingEnabled = true
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
