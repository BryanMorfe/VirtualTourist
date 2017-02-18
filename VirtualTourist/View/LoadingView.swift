//
//  LoadingView.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/16/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    private var dimmerView: UIView!
    private var loadingIndicator: DotLoadingIndicator!
    
    private let maxDimmerOpacity: Float = 0.6
    private let animationInterval: TimeInterval = 0.3
    
    var isLoading: Bool = false
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        
        dimmerView = UIView()
        dimmerView.frame = frame
        dimmerView.backgroundColor = .black
        dimmerView.layer.opacity = 0
        
        loadingIndicator = DotLoadingIndicator()
        loadingIndicator.dotStyle = .largeWhite
        loadingIndicator.frame.origin = CGPoint(x: (frame.size.width / 2) - (loadingIndicator.frame.size.width / 2), y: (frame.size.height / 2) - (loadingIndicator.frame.size.height / 2))
        loadingIndicator.layer.opacity = 1
        
        addSubview(dimmerView)
        addSubview(loadingIndicator)
        
        isHidden = true
    }
    
    func startLoading() {
        isLoading = true
        isHidden = false
        loadingIndicator.startAnimation()
        UIView.animate(withDuration: animationInterval) { 
            self.dimmerView.layer.opacity = self.maxDimmerOpacity
            self.loadingIndicator.layer.opacity = 1
        }
        
    }
    
    func stopLoading() {
        Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: false) { (_) in
            self.isHidden = true
            self.loadingIndicator.stopAnimation()
            self.isLoading = false
        }
        
        UIView.animate(withDuration: animationInterval) { 
            self.dimmerView.layer.opacity = 0
            self.loadingIndicator.layer.opacity = 0
        }
    }

}
