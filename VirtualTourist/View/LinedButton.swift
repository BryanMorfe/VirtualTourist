//
//  LinedButton.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class LinedButton: UIButton {
    
    // MARK: Properties
    
    let defaultBorderWidth: CGFloat = 1
    let defaultCornerRadius: CGFloat = 5
    
    let defaultFontSize: CGFloat = 17
    let defaultFontName = ".SFUIText-Light"
    
    let defaultHeight: CGFloat = 44
    
    var defaultColor: UIColor = .white
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                isUserInteractionEnabled = true
                setTitleColor(defaultColor, for: .normal)
                layer.borderColor = defaultColor.cgColor
            } else {
                isUserInteractionEnabled = false
                setTitleColor(.lightGray, for: .normal)
                layer.borderColor = UIColor.lightGray.cgColor
            }
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        configure()
    }

    private func configure() {
        
        // Background
        backgroundColor = nil
        
        // Border
        layer.borderColor = defaultColor.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = defaultCornerRadius
        layer.masksToBounds = true
        
        // Label
        titleLabel?.font = UIFont(name: defaultFontName, size: defaultFontSize)
        setTitleColor(defaultColor, for: .normal)
        // setTitleColor(.lightGray, for: .disabled)
        
        // Layout
        frame.size.height = defaultHeight
    }
    
    // MARK: Setters
    
    func setButton(to color: UIColor) {
        layer.borderColor = color.cgColor
        setTitleColor(color, for: .normal)
        defaultColor = color
    }
    
    // MARK: Tracking
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        layer.opacity *= 0.2
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) { 
            self.layer.opacity *= 5
        }
        
    }
    
    override func cancelTracking(with event: UIEvent?) {
        UIView.animate(withDuration: 0.3) {
            self.layer.opacity *= 5
        }
    }
    
}
