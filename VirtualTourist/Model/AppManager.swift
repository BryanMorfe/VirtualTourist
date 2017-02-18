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
            let latitude = UserDefaults.standard.value(forKey: Constants.mapLatitude) as? Double,
            let longitude = UserDefaults.standard.value(forKey: Constants.mapLongitude) as? Double {
            
            self.latitudeDelta = latitudeDelta
            self.longitudeDelta = longitudeDelta
            self.latitude = latitude
            self.longitude = longitude
            
        }
        
    }
    
    func saveAppState() {
        
        // This method is called whenever the app goes into background or app terminates
        
        if let latitudeDelta = latitudeDelta, let longitudeDelta = longitudeDelta, let latitude = latitude, let longitude = longitude {
            UserDefaults.standard.set(latitudeDelta, forKey: Constants.mapLatitudeDelta)
            UserDefaults.standard.set(longitudeDelta, forKey: Constants.mapLongitudeDelta)
            UserDefaults.standard.set(latitude, forKey: Constants.mapLatitude)
            UserDefaults.standard.set(longitude, forKey: Constants.mapLongitude)
            
            print("Saved...")
            print("New values:")
            print("Latitude Delta: \(UserDefaults.standard.value(forKey: Constants.mapLatitudeDelta) as! Double)")
            print("Longitude Delta: \(UserDefaults.standard.value(forKey: Constants.mapLongitudeDelta) as! Double)")
            print("Latitude: \(UserDefaults.standard.value(forKey: Constants.mapLatitude) as! Double)")
            print("Longitude: \(UserDefaults.standard.value(forKey: Constants.mapLongitude) as! Double)")
        }
        
    }
    
}
