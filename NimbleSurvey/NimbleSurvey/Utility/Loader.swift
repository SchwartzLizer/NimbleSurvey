//
//  Loader.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

class Loader {

    // MARK: Lifecycle

    private init() { }

    // MARK: Internal

    // MARK: - Shared Instance
    static let shared = Loader()

    // MARK: - Loader
    var loader: UIActivityIndicatorView?
    var backgroundView: UIView?

    // MARK: - Show Loader
    func showLoader(view: UIView) {
        if self.loader == nil {
            self.backgroundView = UIView(frame: view.bounds)
            self.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.3)


            self.loader = UIActivityIndicatorView(style: .whiteLarge)
            self.loader?.center = view.center
            self.loader?.hidesWhenStopped = true
            self.loader?.startAnimating()


            if let background = backgroundView {
                view.addSubview(background)
            }
            view.addSubview(self.loader!)
            view.bringSubviewToFront(self.loader!)
        }
    }

    // MARK: - Hide Loader
    func hideLoader() {
        if self.loader != nil {
            self.loader?.stopAnimating()
            self.loader?.removeFromSuperview()
            self.backgroundView?.removeFromSuperview()
            self.loader = nil
            self.backgroundView = nil
        }
    }
}
