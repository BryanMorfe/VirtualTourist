//
//  FlightInstructionsViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class FlightInstructionsViewController: UIViewController {
    
    var finishButton: LinedButton!
    var blueView: BlueGradientView!
    
    let titleFont = UIFont(name: ".SFUIDisplay-Light", size: 25)
    let descriptionFont = UIFont(name: ".SFUIText-Light", size: 17)
    let defaultFontColor = UIColor.white
    
    override var shouldAutorotate: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppManager.main.isFirstLaunch == true {
            performWelcomeAnimation()
            performInstructionsAnimation(byWaiting: 6)
        } else {
            performInstructionsAnimation(byWaiting: 0)
        }
    }
    
    func setup() {
        
        // Gradient
        let blueView = BlueGradientView()
        view.addSubview(blueView)
        
        // Exit Button
        let buttonFrame = CGRect(x: view.frame.size.width * 0.30, y: view.frame.size.height - 100, width: view.frame.size.width * 0.40, height: 44)
        finishButton = LinedButton(frame: buttonFrame)
        finishButton.setTitle("Finish", for: .normal)
        finishButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        view.addSubview(finishButton)
        
    }
    
    func performWelcomeAnimation() {
        
        finishButton.isEnabled = false
        
        // Title label
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: view.frame.size.width * 0.10, y: 60, width: view.frame.size.width * 0.80, height: 44)
        titleLabel.text = "Welcome to VirtualTourist"
        titleLabel.font = titleFont
        titleLabel.textColor = defaultFontColor
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.layer.opacity = 0
        
        // Description label
        let descriptionLabel = UILabel()
        descriptionLabel.frame = CGRect(x: view.frame.size.width * 0.10, y: (view.frame.size.height / 2) - 22, width: view.frame.size.width * 0.80, height: 80)
        descriptionLabel.font = descriptionFont
        descriptionLabel.textColor = defaultFontColor
        descriptionLabel.numberOfLines = 4
        descriptionLabel.text = "The most realiable and fastest way to see the world. Guaranteed."
        descriptionLabel.textAlignment = .center
        view.addSubview(descriptionLabel)
        descriptionLabel.layer.opacity = 0
        
        
        // Start animmation
        UIView.animate(withDuration: 3, animations: {
            titleLabel.layer.opacity = 1
        }) { (_) in
            UIView.animate(withDuration: 3, animations: {
                descriptionLabel.layer.opacity = 1
            }, completion: { (_) in
                UIView.animate(withDuration: 3, animations: {
                    titleLabel.layer.opacity = 0
                }, completion: { (_) in
                    titleLabel.removeFromSuperview()
                    UIView.animate(withDuration: 3, animations: { 
                        descriptionLabel.layer.opacity = 0
                    }, completion: { (_) in
                        descriptionLabel.removeFromSuperview()
                        self.finishButton.isEnabled = true
                    })
                })
            })
        }
    }
    
    func performInstructionsAnimation(byWaiting time: TimeInterval) {
        
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (_) in
            self.blueView.setTitle(to: "Instructions", animated: true) {
                self.blueView.setMessage(to: "To travel, just long press a location in the traveling map and let the magic happen.", animated: true)
            }
        }
        
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }
    
    

}
