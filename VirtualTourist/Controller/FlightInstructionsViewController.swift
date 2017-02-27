//
//  FlightInstructionsViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit

class FlightInstructionsViewController: UIViewController {
    
    // MARK: Properties
    
    var finishButton: LinedButton!
    var blueView: BlueGradientView!
    
    let titleFont = UIFont(name: ".SFUIDisplay-Light", size: 25)
    let descriptionFont = UIFont(name: ".SFUIText-Light", size: 17)
    let defaultFontColor = UIColor.white
    
    override var shouldAutorotate: Bool {
        return false
    }

    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if AppManager.main.isFirstLaunch == true {
            AppManager.main.isFirstLaunch = false
            performWelcomeAnimation {
                self.performInstructionsAnimation()
            }
        } else {
            performInstructionsAnimation()
        }
    }
    
    func setup() {
        
        blueView = BlueGradientView()
        blueView.animationInterval = 2
        view.addSubview(blueView)
        
        // Exit Button
        let buttonFrame = CGRect(x: view.frame.size.width * 0.30, y: view.frame.size.height - 100, width: view.frame.size.width * 0.40, height: 44)
        finishButton = LinedButton(frame: buttonFrame)
        finishButton.setTitle("Finish", for: .normal)
        finishButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
        view.addSubview(finishButton)
        
    }
    
    func performWelcomeAnimation(completion handler: @escaping (Void) -> Void) {
        
        // Takes advantages of the BlueGradientView to animate a welcome screen for new users
        
        finishButton.isEnabled = false
        
        blueView.setTitle(to: "Welcome to VirtualTourist", animated: true) {
            self.blueView.setMessage(to: "The most realiable and fastest way to see the world. Guaranteed.", animated: true) {
                self.finishButton.isEnabled = true
                handler()
            }
        }
        
    }
    
    func performInstructionsAnimation() {
        
        // Displays the instructions in an animated manner to users
        
        blueView.setTitle(to: "Instructions", animated: true) {
            self.blueView.animationInterval = 3
            self.blueView.setMessage(to: "To set a destination, just search for a location or manually find it on the traveling map.", animated: true) {
                self.blueView.setMessage(to: "After you have your location, long press it to set it as a destination", animated: true) {
                    self.blueView.setMessage(to: "One the location is set, tap on it and experience the magic.", animated: true)
                }
            }
        }
    }
    
    func finish() {
        dismiss(animated: true, completion: nil)
    }

}
