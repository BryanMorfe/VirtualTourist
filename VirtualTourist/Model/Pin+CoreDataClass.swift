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
    
    convenience init(latitude: Double, longitude: Double, photos: NSSet, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            self.init(entity: entity, insertInto: context)
            self.latitude = latitude
            self.longitude = longitude
            self.addToPhotos(photos)
        } else {
            fatalError("Could not create entity with provided context")
        }
    }
    
}
