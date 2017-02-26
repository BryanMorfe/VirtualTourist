//
//  BlueGradientView.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/15/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class BlueGradientView: UIView {

    var titleLabel: UILabel!
    var messageLabel: UILabel!
    
    var animationInterval: TimeInterval = 1
    var waitingAnimationInterval: TimeInterval = 3
    
    private let defaultTitleFont = UIFont(name: ".SFUIDisplay-Light", size: 25)
    private let defaultMessageFont = UIFont(name: ".SFUIText-Light", size: 17)
    private let defaultFontColor = UIColor.white
    
    private var isAnimatingTitle: Bool = false
    private var isAnimatingMessage: Bool = false
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        
        // Gradient
        let gradient = CAGradientLayer()
        gradient.colors = [ViewInterface.Constants.Colors.lightBlue.cgColor, ViewInterface.Constants.Colors.cyan.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        gradient.frame = frame
        layer.addSublayer(gradient)
        
        // Title Label
        titleLabel = UILabel()
        titleLabel.frame = CGRect(x: frame.size.width * 0.10, y: 60, width: frame.size.width * 0.80, height: 44)
        titleLabel.font = defaultTitleFont
        titleLabel.textColor = defaultFontColor
        titleLabel.textAlignment = .center
        titleLabel.layer.opacity = 0
        addSubview(titleLabel)
        
        // Message Label
        messageLabel = UILabel()
        messageLabel.frame = CGRect(x: frame.size.width * 0.10, y: (frame.size.height / 2) - 22, width: frame.size.width * 0.80, height: 100)
        messageLabel.font = defaultMessageFont
        messageLabel.textColor = defaultFontColor
        messageLabel.numberOfLines = 4
        messageLabel.textAlignment = .center
        messageLabel.layer.opacity = 0
        addSubview(messageLabel)
    }
    
    // MARK: Setters
    /* Should add feature that allows text to be retained for certain ammount of time before it's changed */
    func setTitle(to title: String, animated: Bool, completion handler: ((Void) -> (Void))? = nil) {
        
        if isAnimatingTitle {
            return
        }
        
        if titleLabel.layer.opacity > 0 {
            
            if animated {
                isAnimatingTitle = true
                Timer.scheduledTimer(withTimeInterval: waitingAnimationInterval, repeats: false, block: {
                    (_) in
                    
                    UIView.animate(withDuration: self.animationInterval, animations: {
                        self.titleLabel.layer.opacity = 0
                    }, completion: { (_) in
                        self.titleLabel.text = title
                        Timer.scheduledTimer(withTimeInterval: self.animationInterval, repeats: false, block: { (_) in
                            self.isAnimatingTitle = false
                            if let handler = handler {
                                handler()
                            }
                        })
                        UIView.animate(withDuration: self.animationInterval, animations: {
                            self.titleLabel.layer.opacity = 1
                        })
                    })
                    
                })
            }
            
        } else {
            
            self.titleLabel.text = title
            if animated {
                isAnimatingTitle = true
                UIView.animate(withDuration: animationInterval, animations: { 
                    self.titleLabel.layer.opacity = 1
                }, completion: {
                    (_) in
                    if let handler = handler {
                        handler()
                    }
                    self.isAnimatingTitle = false
                })
            } else {
                titleLabel.layer.opacity = 1
            }
            
        }
        
    }
    
    func setMessage(to message: String, animated: Bool, completion handler: ((Void) -> (Void))? = nil) {
        
        if isAnimatingMessage {
            return
        }
        
        if messageLabel.layer.opacity > 0 {
            
            if animated {
                isAnimatingMessage = true
                Timer.scheduledTimer(withTimeInterval: waitingAnimationInterval, repeats: false, block: {
                    (_) in
                    
                    UIView.animate(withDuration: self.animationInterval, animations: {
                        self.messageLabel.layer.opacity = 0
                    }, completion: { (_) in
                        self.messageLabel.text = message
                        Timer.scheduledTimer(withTimeInterval: self.animationInterval, repeats: false, block: { (_) in
                            self.isAnimatingMessage = false
                            if let handler = handler {
                                handler()
                            }
                        })
                        UIView.animate(withDuration: self.animationInterval, animations: {
                            self.messageLabel.layer.opacity = 1
                        })
                    })
                    
                })
            }
            
        } else {
            
            messageLabel.text = message
            if animated {
                isAnimatingMessage = true
                UIView.animate(withDuration: animationInterval, animations: {
                    self.messageLabel.layer.opacity = 1
                }, completion: {
                    (_) in
                    self.isAnimatingMessage = false
                    if let handler = handler {
                        handler()
                    }
                })
            } else {
                messageLabel.layer.opacity = 1
            }
            
        }
        
    }

}
