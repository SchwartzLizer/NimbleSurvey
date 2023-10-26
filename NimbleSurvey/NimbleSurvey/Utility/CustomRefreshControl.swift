//
//  CustomRefreshControl.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class CustomRefreshControl: UIView {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupRefreshControl()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupRefreshControl()
    }

    // MARK: Public

    public func startAnimating() {
        self.activityIndicator.startAnimating()
    }

    public func stopAnimating() {
        self.activityIndicator.stopAnimating()
    }

    public func resetControl() {
        self.stopAnimating()
        // Other reset related code can be added here
    }

    // MARK: Private

    private var activityIndicator = UIActivityIndicatorView()

    private func setupRefreshControl() {
        self.activityIndicator.style = .whiteLarge
        self.activityIndicator.color = .white
        addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

}
