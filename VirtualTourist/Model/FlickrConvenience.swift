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
    
    func getImages(from latitude: Double, longitude: Double, completion handler: @escaping (Bool, String?) -> Void) {
        
        let parameters = [
            Flickr.Constants.ParameterKeys.method : Flickr.Constants.Methods.searchMethod,
            Flickr.Constants.ParameterKeys.safeSearch : Flickr.Constants.ParameterValues.enableSafeSearch,
            Flickr.Constants.ParameterKeys.extras : Flickr.Constants.ParameterValues.mediumURL,
            Flickr.Constants.ParameterKeys.noJSONCallback : Flickr.Constants.ParameterValues.disableJSONCallback,
            Flickr.Constants.ParameterKeys.responseFormat : Flickr.Constants.ParameterValues.jsonFormat,
            Flickr.Constants.ParameterKeys.boundingBox : makeBoundingBox(from: latitude, longitude: longitude)
        ]
        
        taskForGet(with: parameters as [String: AnyObject]) {
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
            
            var photos = [Photo]()
            
            let pin = Pin(latitude: latitude, longitude: longitude, photos: nil, context: AppManager.main.coreDataStack.context)
            
            for photoDictionary in photosArray {
                let photo = Photo(photoDictionary: photoDictionary, context: AppManager.main.coreDataStack.context)
                photo.pin = pin
                photos.append(photo)
            }
            pin.photos = NSSet()
            pin.photos?.addingObjects(from: photos)
            
            AppManager.main.currentPin = pin
            AppManager.main.pins.append(pin)
            
            handler(true, nil)
            
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
