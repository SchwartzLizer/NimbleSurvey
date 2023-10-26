//
//  UIImageView+Extension.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import UIKit

extension UIImageView {
    func dim(with level: CGFloat) {
        let dimView = UIView(frame: bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(level)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(dimView)
    }
}
