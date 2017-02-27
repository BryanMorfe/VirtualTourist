//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/18/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    
    // MARK: Initializer
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: AppManager.Constants.EntityNames.pin, in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            fatalError("Could not create entity with provided context.")
        }
        
    }
    
}

extension Pin {
    static func ==(lhs: Pin, rhs: Pin) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
