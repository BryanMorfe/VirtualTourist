//
//  AppManagerConstants.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/18/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import Foundation

// MARK: AppManager Constants

extension AppManager {
    
    struct Constants {
        
        struct App {
            static let launchState = "hasLaunched"
            static let mapState = "mapState"
            static let modelName = "VirtualTouristModel"
        }
        
        struct MapState {
            static let latitudeDelta = "latitudeDelta"
            static let longitudeDelta = "longitudeDelta"
            static let latitude = "latitude"
            static let longitude = "longitude"
        }
        
        struct EntityNames {
            static let pin = "Pin"
            static let photo = "Photo"
        }
        
    }
    
}
