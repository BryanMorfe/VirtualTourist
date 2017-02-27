//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import Foundation

// MARK: Convenience Methods

extension Flickr {
    
    private func getNumberOfPages(from latitude: Double, longitude: Double, completion handler: @escaping (Int?, String?) -> Void) {
        
        // This method gets the maximum allowed number of pages.
        
        // Setup Parameters
        let parameters = [
            Constants.ParameterKeys.method : Constants.Methods.searchMethod as AnyObject,
            Constants.ParameterKeys.safeSearch : Constants.ParameterValues.enableSafeSearch as AnyObject,
            Constants.ParameterKeys.extras : Constants.ParameterValues.mediumURL as AnyObject,
            Constants.ParameterKeys.noJSONCallback : Constants.ParameterValues.disableJSONCallback as AnyObject,
            Constants.ParameterKeys.responseFormat : Constants.ParameterValues.jsonFormat as AnyObject,
            Constants.ParameterKeys.perPage : Constants.ParameterValues.perPage as AnyObject,
            Constants.ParameterKeys.boundingBox : makeBoundingBox(from: latitude, longitude: longitude) as AnyObject
            ] as [String : AnyObject]
        
        // Start GET Request
        taskForGet(with: parameters) {
            (data, error) in
            
            // Error handling
            guard error == nil else {
                handler(nil, "Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                handler(nil, "Error while retrieving the data.")
                return
            }
            
            // Data parsing
            guard let photosDictionary = data[Constants.JSONResponseKeys.photos] as? [String : AnyObject] else {
                handler(nil, "Error retrieving photos dictionary.")
                return
            }
            
            guard let numberOfPages = photosDictionary[Constants.JSONResponseKeys.pages] as? Int, numberOfPages > 0 else {
                handler(nil, "Error getting number of pages.")
                return
            }
            
            // Get me the number of pages if is less than the the page containing the 4000th image.
            let maximumPageNumber = min(numberOfPages, Int(ceil(4000 / Double(numberOfPages))))
                
            handler(maximumPageNumber, nil)
            
        }
        
    }
    
    func getImages(from latitude: Double, longitude: Double, completion handler: @escaping (Bool, String?) -> Void) {
        
        // This method downloads the data from Flickr and creates the Managed Objects in Background
        
        // Get number of pages.
        getNumberOfPages(from: latitude, longitude: longitude) {
            (numberOfPages, errorString) in
            
            // Try to find a page, if any, else just choose page 1.
            let randomPage = Int(arc4random_uniform(UInt32(numberOfPages ?? 0)) + 1)
            
            // Setup parameters
            let parameters = [
                Constants.ParameterKeys.method : Constants.Methods.searchMethod as AnyObject,
                Constants.ParameterKeys.safeSearch : Constants.ParameterValues.enableSafeSearch as AnyObject,
                Constants.ParameterKeys.extras : Constants.ParameterValues.mediumURL as AnyObject,
                Constants.ParameterKeys.noJSONCallback : Constants.ParameterValues.disableJSONCallback as AnyObject,
                Constants.ParameterKeys.responseFormat : Constants.ParameterValues.jsonFormat as AnyObject,
                Constants.ParameterKeys.perPage : Constants.ParameterValues.perPage as AnyObject,
                Constants.ParameterKeys.boundingBox : self.makeBoundingBox(from: latitude, longitude: longitude) as AnyObject,
                Constants.ParameterKeys.page : randomPage as AnyObject
            ] as [String : AnyObject]
            
            // Start GET Task
            self.taskForGet(with: parameters) {
                (data, error) in
                
                // Error handling
                guard error == nil else {
                    handler(false, "Error: \(error!.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    handler(false, "Error while retrieving the data.")
                    return
                }
                
                // Data parsing
                guard let photosDictionary = data[Constants.JSONResponseKeys.photos] as? [String : AnyObject] else {
                    handler(false, "Error retrieving photos dictionary.")
                    return
                }
                    
                guard let photosArray = photosDictionary[Constants.JSONResponseKeys.photo] as? [[String : AnyObject]] else {
                    handler(false, "Error accessing array of photos.")
                    return
                }
                
                // Get the amount of photos that are in the current page
                var total = Int(photosDictionary[Constants.JSONResponseKeys.total] as! String)!
                let perPage = Constants.ParameterValues.perPage
                
                // If we selected the last page, we have to select the remainder of 4000 to the number of pages
                // because that's the amount of photos in the last page
                /* THIS IS CAUSING A BUG */
                if let pagesNumber = numberOfPages, pagesNumber == randomPage {
                    total = min(total, 4000)
                    let numOfPhotos = Double(total).truncatingRemainder(dividingBy: Double(perPage)) > 0 ? Double(total).truncatingRemainder(dividingBy: Double(perPage)) : Double(total)
                    print(total)
                    print(pagesNumber)
                    print(numOfPhotos)
                    AppManager.main.expectedPhotoAmount = Int(numOfPhotos)
                } else {
                    // Otherwise, check if there are less photos than the amount per page and assign it
                    AppManager.main.expectedPhotoAmount = min(total, perPage)
                }
                
                // Create a reference to the current Pin (current Pin is set when is tapped on in TravelMapViewController)
                var pin = AppManager.main.currentPin!
                
                // If the current pin is not in the background context (It existed before and it was loaded into main context
                // We have to find the same Pin Managed Object that is in the background context.
                // We know that if we have Managed Objects trying to set relationship while in different queues, it will cause
                // the app to crash.
                if pin.managedObjectContext! !== AppManager.main.coreDataStack.backgroundContext {
                    pin = AppManager.main.coreDataStack.backgroundContext.object(with: pin.objectID) as! Pin
                    AppManager.main.currentPin = pin
                }
                    
                for photoDictionary in photosArray {
                    AppManager.main.coreDataStack.performBackgroundBatchOperations(batch: { (backgroundContext) in
                        // The instance of Photo is added to the context automatically at initialization
                        // Because Pin and Photo have an inverse relationship, if I assign a Pin to a Photo object, the Photo object
                        // is automatically added to the Pin's set of photos
                        // so there is no need to add the photos to the Pin managed object
                        let _ = Photo(pin: pin, photoDictionary: photoDictionary, context: backgroundContext)
                    })
                }
                
                // If this pin is not in all loaded pins because it's new, then add it
                if !AppManager.main.pins.contains(pin) {
                    AppManager.main.pins.append(pin)
                }
                
                handler(true, nil)
                    
            }
            
        }

    }
    
    func makeURL(from parameters: [String : AnyObject]) -> URL? {
    
        // Builds a url from the passed parameters
        
        var components = URLComponents()
        components.scheme = Flickr.Constants.URL.scheme
        components.host = Flickr.Constants.URL.host
        components.path = Flickr.Constants.URL.path
        
        var queries = [URLQueryItem]()
        
        for (key, value) in parameters {
            let query = URLQueryItem(name: key, value: "\(value)")
            queries.append(query)
        }
        
        components.queryItems = queries
        
        return components.url
    }
    
    func convert(data: Data, completion handler: @escaping (AnyObject?, NSError?) -> Void) {
     
        // Attemps to convert data to JSON Obj or returns nil with an error
        
        let parsedData: AnyObject!
        
        do {
            parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse data as JSON Object."]
            let error = NSError(domain: "convert", code: 1, userInfo: userInfo)
            handler(nil, error)
            return
        }
        
        handler(parsedData, nil)
        
    }

    private func makeBoundingBox(from latitude: Double, longitude: Double) -> String {
        
        // Creates a bounding box for Flickr parameter
        
        let difference: Double = 1
        
        let minLongitude = max(longitude - difference, -180)
        let minLatitud = max(latitude - difference, -90)
        
        let maxLongitude = min(longitude + difference, 180)
        let maxLatitud = min(latitude + difference, 90)
        
        return "\(minLongitude), \(minLatitud), \(maxLongitude), \(maxLatitud)"
    }
    
}
