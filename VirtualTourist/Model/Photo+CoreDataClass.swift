//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/18/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {

    convenience init(image: UIImage, title: String, context: NSManagedObjectContext) {
        if let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: entity, insertInto: context)
            self.image = UIImagePNGRepresentation(image)
            self.title = title
        } else {
            fatalError("Could not create entity from context.")
        }
    }
    
}
