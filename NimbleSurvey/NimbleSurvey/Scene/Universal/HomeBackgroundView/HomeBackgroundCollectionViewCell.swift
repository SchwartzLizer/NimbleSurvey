//
//  HomeBackgroundCollectionViewCell.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

// MARK: - HomeBackgroundCollectionViewCell

class HomeBackgroundCollectionViewCell: UICollectionViewCell {

    // MARK: Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        applyTheme()
        setupUI()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleZoomInNotification(_:)),
            name: .zoomInBackground,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleZoomOutNotification(_:)),
            name: .zoomOutBackground,
            object: nil)
    }

    // MARK: Public

    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    public static var identifier: String {
        return String(describing: self)
    }

    // MARK: Internal

    @IBOutlet weak var backgroundImage: UIImageView!

    var viewModel: HomeBackgroundCollectionViewModel? {
        didSet {
            onInitialized()
        }
    }

    // MARK: Private

    private var scrollView: UIScrollView!
    private var customRefreshControl: CustomRefreshControl!
    private var isRefreshing = false
    private let refreshControlHeight: CGFloat = -200
}

// MARK: Action, UIScrollViewDelegate

extension HomeBackgroundCollectionViewCell: Action,UIScrollViewDelegate {

    // MARK: Internal

    @objc
    func scrollViewDidScroll(_: UIScrollView) {
        if !self.isRefreshing && self.scrollView.contentOffset.y < -150 {
            self.startRefreshing()
        }

        if self.isRefreshing && self.scrollView.contentOffset.y == -59 {
            self.endRefreshing()
        }

        if self.scrollView.contentOffset.y > 0 {
            self.scrollView.contentOffset.y = -59 // protect scroll down
        }
    }

    @objc
    func handleZoomInNotification(_: Notification) {
        let zoomScale: CGFloat = 1.30 // 100% + 30%
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundImage.transform = CGAffineTransform(scaleX: zoomScale, y: zoomScale)
        })
    }

    @objc
    func handleZoomOutNotification(_: Notification) {
        UIView.animate(withDuration: 0.5, animations: {
            self.backgroundImage.transform = CGAffineTransform.identity
        })
    }


    // MARK: Private

    private func startRefreshing() {
        self.isRefreshing = true
        self.customRefreshControl.startAnimating()
    }

    private func endRefreshing() {
        self.isRefreshing = false
        self.customRefreshControl.stopAnimating()
        NotificationCenter.default.post(name: .refreshSurvey, object: nil)
    }

}

// MARK: Updated

extension HomeBackgroundCollectionViewCell: Updated {

    // MARK: Internal

    internal func onInitialized() {
        self.onUpdated()
    }

    // MARK: Private

    private func onUpdated() {
        self.backgroundImage.setBackgroundImageFromURL(url: self.viewModel?.url)
    }
}

// MARK: UserInterfaceSetup

extension HomeBackgroundCollectionViewCell: UserInterfaceSetup {

    // MARK: Internal

    internal func setupUI() {
        self.setupScrollView()
    }

    // MARK: Private

    private func setupScrollView() {
        // Set up the scroll view
        self.scrollView = UIScrollView(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height * 0.5))
        self.scrollView.backgroundColor = .clear
        self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 1.5)
        self.scrollView.delegate = self
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)

        // Set up the custom refresh control
        self.customRefreshControl = CustomRefreshControl()
        self.customRefreshControl.frame = CGRect(
            x: 0,
            y: -self.refreshControlHeight,
            width: UIScreen.main.bounds.width,
            height: self.refreshControlHeight)
        self.scrollView.addSubview(self.customRefreshControl)
    }
}

// MARK: ApplyTheme

extension HomeBackgroundCollectionViewCell: ApplyTheme {

    // MARK: Internal

    internal func applyTheme() {
        self.applyThemeBackground()
    }

    // MARK: Private

    private func applyThemeBackground() {
        self.backgroundImage.dim(with: 0.3)
    }
}

