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
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: AppManager.Constants.EntityNames.pin, in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            
        } else {
            fatalError("Could not create entity with provided context.")
        }
        
    }
    
    func hasPhotos() -> Bool {
        if let photos = self.photos {
            return photos.count > 0
        }
        return false
    }
    
}
