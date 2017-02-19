//
//  AppManager.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import Foundation

class AppManager {
    
    // MARK: Properties
    
    static let main = AppManager()
    
    // UserDefaults variables
    var isFirstLaunch: Bool!
    var mapState: [String : AnyObject]?
    
    // Core Data objects
    var pins = [Pin]()
    let coreDataStack = CoreDataStack(modelName: "VirtualTouristModel")!
    
    // MARK: Methods
    
    func configure() {
        
        // This method is called as soon as the app finishes launching in the delegate of the app
        
        if let _ = UserDefaults.standard.value(forKey: Constants.AppState.launchState) as? Bool {
            isFirstLaunch = false
        } else {
            UserDefaults.standard.set(true, forKey: Constants.AppState.launchState)
            isFirstLaunch = true
        }
        
        if let mapState = UserDefaults.standard.value(forKey: Constants.AppState.mapState) as? [String : AnyObject] {
            self.mapState = mapState
        }
        
    }
    
    func saveAppState() {
        
        // This method is called whenever the app goes into background or app terminates
        
        if let mapState = mapState {
            UserDefaults.standard.set(mapState, forKey: Constants.AppState.mapState)
        }
        
    }
    
}
