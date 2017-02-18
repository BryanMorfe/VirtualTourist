//
//  DotLoadingIndicator.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/16/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class DotLoadingIndicator: UIView {
    
    // MARK: Properties
    
    var loadingMode: DotLoadingMode = .smooth
    var dotStyle: DotStyle = .white {
        didSet {
            switch dotStyle {
            case .white:
                defaultDotSize = 10
                defaultDotSpacing = 5
                defaultDotColor = .white
            case .largeWhite:
                defaultDotSize = 15
                defaultDotSpacing = 7.5
                defaultDotColor = .white
            case .gray:
                defaultDotSize = 10
                defaultDotSpacing = 5
                defaultDotColor = .lightGray
            case .largeGray:
                defaultDotSize = 15
                defaultDotSpacing = 7.5
                defaultDotColor = .lightGray
                
            }
            adjustDots()
            frame.size = CGSize(width: (defaultDotSize * 3) + (defaultDotSpacing * 2), height: defaultDotSize)
        }
    }
    
    var isAnimating: Bool = false
    
    /* Private default constants */
    private var loadingDots: [UIView] = []
    private var animationTimer: Timer!
    private var currentDotIndex: Int = 2
    
    private let animationInterval: TimeInterval = 0.5
    private let defaultOpacity: Float = 0.3
    
    private var defaultDotSize: CGFloat = 10
    private var defaultDotSpacing: CGFloat = 5
    private var defaultDotColor: UIColor = .white
    
    // MARK: Initializers
    
    init() {
        let intrinsicFrame = CGRect(x: 0, y: 0,
                                    width: (defaultDotSize * 3) + (defaultDotSpacing * 2),
                                    height: defaultDotSize)
        super.init(frame: intrinsicFrame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Private Methods

    private func configure() {
        
        let dotFrame = CGRect(x: 0, y: 0, width: defaultDotSize, height: defaultDotSize)
        
        let dot = UIView(frame: dotFrame)
        
        let dot2 = UIView(frame: dotFrame)
        dot2.frame.origin.x += defaultDotSize + defaultDotSpacing
        
        let dot3 = UIView(frame: dotFrame)
        dot3.frame.origin.x += 2 * (defaultDotSpacing + defaultDotSize)
        
        loadingDots = [dot, dot2, dot3]
        
        for dot in loadingDots {
            dot.layer.masksToBounds = true
            dot.layer.cornerRadius = defaultDotSize / 2
            dot.backgroundColor = defaultDotColor
            dot.layer.opacity = defaultOpacity
            addSubview(dot)
        }
    
    }
    
    private func adjustDots() {
        
        let shouldAnimate = isAnimating
        if isAnimating {
            stopAnimation()
        }
        
        let dotFrame = CGRect(x: 0, y: 0, width: defaultDotSize, height: defaultDotSize)
        
        for i in 0..<loadingDots.count {
            loadingDots[i].frame = dotFrame
            loadingDots[i].frame.origin.x += (defaultDotSpacing + defaultDotSize) * CGFloat(i)
            loadingDots[i].layer.cornerRadius = defaultDotSize / 2
            loadingDots[i].backgroundColor = defaultDotColor
        }
        
        if shouldAnimate {
            startAnimation()
        }
    }
    
    // MARK: Methods
    
    func startAnimation() {
        
        isAnimating = true
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true, block: {
            (_) in
            let previousDotIndex = self.currentDotIndex
            self.currentDotIndex = self.currentDotIndex == self.loadingDots.count - 1 ?
                                   0 : self.currentDotIndex + 1
            
            switch self.loadingMode {
            case .smooth:
                UIView.animate(withDuration: self.animationInterval, animations: {
                    self.loadingDots[self.currentDotIndex].layer.opacity = 1
                    self.loadingDots[previousDotIndex].layer.opacity = self.defaultOpacity
                })
            case .plain:
                self.loadingDots[self.currentDotIndex].layer.opacity = 1
                self.loadingDots[previousDotIndex].layer.opacity = self.defaultOpacity
            }
        })
        
    }
    
    func stopAnimation() {
        
        guard let timer = animationTimer else {
            return
        }
        
        guard timer.isValid else {
            return
        }
        
        timer.invalidate()
        for dot in loadingDots {
            dot.layer.opacity = defaultOpacity
            currentDotIndex = 0
        }
        isAnimating = false
    }

}

// MARK: Enumerations

extension DotLoadingIndicator {
    
    enum DotLoadingMode {
        case smooth, plain
    }
    
    enum DotStyle {
        case white, largeWhite, gray, largeGray
    }
    
}
