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
    
    // MARK: Initializer

    convenience init(pin: Pin, photoDictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: AppManager.Constants.EntityNames.photo, in: context) {
            
            self.init(entity: entity, insertInto: context)
            
            self.pin = pin
            
            guard let title = photoDictionary[Flickr.Constants.JSONResponseKeys.title] as? String else {
                fatalError("Could not retrieve the title of the photo.")
            }
            
            self.title = title
            
            guard let imageURLString = photoDictionary[Flickr.Constants.JSONResponseKeys.mediumURL] as? String else {
                fatalError("Could not retrieve url for image.")
            }
            
            guard let imageURL = URL(string: imageURLString) else {
                fatalError("Could not create url from: \(imageURLString)")
            }
            
            var imageData: Data!
            
            do {
                imageData = try Data(contentsOf: imageURL)
            } catch {
                fatalError("Could not create data from url: \(imageURL)")
            }

            image = imageData

        } else {
            fatalError("Could not create entity from context.")
        }
        
    }
    
}
