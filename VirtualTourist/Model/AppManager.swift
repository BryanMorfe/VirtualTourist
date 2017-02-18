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
    
    var isFirstLaunch: Bool!
    var latitudeDelta: Double?
    var longitudeDelta: Double?
    var latitude: Double?
    var longitude: Double?
    
    // MARK: Methods
    
    func configure() {
        
        // This method is called as soon as the app finishes launching in the delegate of the app
        
        if let _ = UserDefaults.standard.value(forKey: Constants.launchState) as? Bool {
            isFirstLaunch = false
        } else {
            UserDefaults.standard.set(true, forKey: Constants.launchState)
            isFirstLaunch = true
        }
        
        if let latitudeDelta = UserDefaults.standard.value(forKey: Constants.mapLatitudeDelta) as? Double,
            let longitudeDelta = UserDefaults.standard.value(forKey: Constants.mapLongitudeDelta)  as? Double,
            let latitude = UserDefaults.standard.value(forKey: Constants.mapLatitud) as? Double,
            let longitude = UserDefaults.standard.value(forKey: Constants.mapLongitud) as? Double {
            
            self.latitudeDelta = latitudeDelta
            self.longitudeDelta = longitudeDelta
            self.latitude = latitude
            self.longitude = longitude
            
        }
        
    }
    
}
