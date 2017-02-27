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
        
        let parameters = [
            Constants.ParameterKeys.method : Constants.Methods.searchMethod as AnyObject,
            Constants.ParameterKeys.safeSearch : Constants.ParameterValues.enableSafeSearch as AnyObject,
            Constants.ParameterKeys.extras : Constants.ParameterValues.mediumURL as AnyObject,
            Constants.ParameterKeys.noJSONCallback : Constants.ParameterValues.disableJSONCallback as AnyObject,
            Constants.ParameterKeys.responseFormat : Constants.ParameterValues.jsonFormat as AnyObject,
            Constants.ParameterKeys.perPage : Constants.ParameterValues.perPage as AnyObject,
            Constants.ParameterKeys.boundingBox : makeBoundingBox(from: latitude, longitude: longitude) as AnyObject
            ] as [String : AnyObject]
        
        taskForGet(with: parameters) {
            (data, error) in
            
            guard error == nil else {
                handler(nil, "Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                handler(nil, "Error while retrieving the data.")
                return
            }
            
            guard let photosDictionary = data[Constants.JSONResponseKeys.photos] as? [String : AnyObject] else {
                handler(nil, "Error retrieving photos dictionary.")
                return
            }
            
            guard let numberOfPages = photosDictionary[Constants.JSONResponseKeys.pages] as? Int, numberOfPages > 0 else {
                handler(nil, "Error getting number of pages.")
                return
            }
            
            let maximumPageNumber = min(numberOfPages, Int(ceil(4000 / Double(numberOfPages))))
                
            handler(maximumPageNumber, nil)
            
        }
        
    }
    
    func getImages(from latitude: Double, longitude: Double, completion handler: @escaping (Bool, String?) -> Void) {
        
        getNumberOfPages(from: latitude, longitude: longitude) { (numberOfPages, errorString) in
            
            if numberOfPages != nil {
                
                let randomPage = arc4random_uniform(UInt32(numberOfPages!)) + 1
                
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
                
                self.taskForGet(with: parameters) {
                    (data, error) in
                    
                    guard error == nil else {
                        handler(false, "Error: \(error!.localizedDescription)")
                        return
                    }
                    
                    guard let data = data else {
                        handler(false, "Error while retrieving the data.")
                        return
                    }
                    
                    guard let photosDictionary = data[Constants.JSONResponseKeys.photos] as? [String : AnyObject] else {
                        handler(false, "Error retrieving photos dictionary.")
                        return
                    }
                    
                    guard let photosArray = photosDictionary[Constants.JSONResponseKeys.photo] as? [[String : AnyObject]] else {
                        handler(false, "Error accessing array of photos.")
                        return
                    }
                    
                    let total = Int(photosDictionary[Constants.JSONResponseKeys.total] as! String)!
                    let perPage = Constants.ParameterValues.perPage
                    AppManager.main.expectedPhotoAmount = total < perPage ? total : perPage
                    
                    var pin = AppManager.main.currentPin!
                    
                    // If the current pin
                    if pin.managedObjectContext! !== AppManager.main.coreDataStack.backgroundContext {
                        pin = AppManager.main.coreDataStack.backgroundContext.object(with: pin.objectID) as! Pin
                        AppManager.main.currentPin = pin
                    }
                    
                    for photoDictionary in photosArray {
                        AppManager.main.coreDataStack.performBackgroundBatchOperations(batch: { (backgroundContext) in
                            // The instance of Photo is added to the context automatically at initialization
                            // Because Pin and Photo have an inverse relationship, if I assign a Pin to a Photo object, the Photo object
                            // is automatically added to the Pin's set of photos
                            let _ = Photo(pin: pin, photoDictionary: photoDictionary, context: backgroundContext)
                        })
                    }
                    
                    AppManager.main.pins.append(pin)
                    
                    handler(true, nil)
                    
                }
                
            } else {
                
                handler(false, errorString)
                
            }
            
        }
    }
    
    func makeURL(from parameters: [String : AnyObject]) -> URL? {
        
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
        
        let difference: Double = 1
        
        let minLongitude = max(longitude - difference, -180)
        let minLatitud = max(latitude - difference, -90)
        
        let maxLongitude = min(longitude + difference, 180)
        let maxLatitud = min(latitude + difference, 90)
        
        return "\(minLongitude), \(minLatitud), \(maxLongitude), \(maxLatitud)"
    }
    
}
