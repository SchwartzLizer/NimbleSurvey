//
//  CustomPageControl.swift
//  NimbleSurvey
//
//  Created by Tanatip Denduangchai on 10/27/23.
//

import Foundation

import UIKit

// MARK: - CustomPageControl

class CustomPageControl: UIView {

    // MARK: Lifecycle

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Internal

    // MARK: - Properties
    var numberOfPages = 0 {
        didSet {
            self.setupDots()
        }
    }

    var currentPage = 0 {
        didSet {
            self.updateDots()
        }
    }

    // MARK: Private

    private var dots = [CustomDot]()

    // MARK: - Setup
    private func setupDots() {
        for dot in self.dots {
            dot.removeFromSuperview()
        }

        self.dots.removeAll()

        for _ in 0..<self.numberOfPages {
            let dot = CustomDot()
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.isActive = false
            dot.layer.cornerRadius = 4 // Half of the dot width
            addSubview(dot)
            self.dots.append(dot)
        }

        self.configureConstraints()
    }

    private func configureConstraints() {
        var previousDot: CustomDot?

        for dot in self.dots {
            dot.widthAnchor.constraint(equalToConstant: 8).isActive = true
            dot.heightAnchor.constraint(equalToConstant: 8).isActive = true
            dot.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

            if let previous = previousDot {
                dot.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: 10).isActive = true
            } else {
                dot.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            }

            previousDot = dot
        }
    }

    private func updateDots() {
        for (index, dot) in self.dots.enumerated() {
            dot.isActive = index == self.currentPage
        }
    }
}

// MARK: - CustomDot

class CustomDot: UIView {

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupBlurEffect()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupBlurEffect()
    }

    // MARK: Internal

    var isActive = false {
        didSet {
            self.updateAppearance()
        }
    }

    // MARK: Private

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        blurEffectView.layer.cornerRadius = 4
        blurEffectView.clipsToBounds = true
        return blurEffectView
    }()

    private func setupBlurEffect() {
        addSubview(self.blurEffectView)
        self.blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        self.blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        self.blurEffectView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        self.blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        self.updateAppearance()
    }

    private func updateAppearance() {
        if self.isActive {
            backgroundColor = .white
            self.blurEffectView.isHidden = true
        } else {
            backgroundColor = .clear
            self.blurEffectView.isHidden = false
        }
    }
}
