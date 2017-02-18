//
//  BlueLoadingView.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/17/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class BlueLoadingView: BlueGradientView {
    
    var isLoading: Bool = false

    private var loadingIndicator: DotLoadingIndicator!
    
    override init() {
        super.init()
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configure() {
        
        loadingIndicator = DotLoadingIndicator()
        loadingIndicator.dotStyle = .largeWhite
        loadingIndicator.frame.origin = CGPoint(x: (frame.size.width / 2) - (loadingIndicator.frame.size.width / 2), y: messageLabel.frame.origin.y + messageLabel.frame.size.height + 50)
        addSubview(loadingIndicator)
        loadingIndicator.isHidden = true
        
    }
    
    func startLoading() {
        isLoading = true
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation()
    }
    
    func stopLoading() {
        isLoading = false
        
        loadingIndicator.isHidden = true
        loadingIndicator.stopAnimation()
    }

}
