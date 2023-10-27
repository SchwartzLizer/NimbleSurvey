//
//  Kingfisher+Extension.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Kingfisher
import UIKit

extension UIImageView {
    func setBackgroundImageFromURL(url: URL?, placeholder: UIImage? = nil) {
        let processor = DownsamplingImageProcessor(size: UIScreen.main.bounds.size)
        self.contentMode = .scaleAspectFill
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .processor(processor),
                .transition(.fade(0.3)),
            ]) { result in
                switch result {
                case .success: break
                case .failure: break
                }
            }
    }

    func setProfileFromURL(url: URL?, placeholder: UIImage? = nil) {
        let processor = DownsamplingImageProcessor(size: self.bounds.size) |>
            RoundCornerImageProcessor(cornerRadius: self.bounds.size.height / 2)
        self.contentMode = .scaleAspectFill
        self.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .processor(processor),
                .transition(.fade(0.3)),
            ]) { result in
                switch result {
                case .success: break
                case .failure: break
                }
            }
    }
}

