//
//  Flickr.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import Foundation

class Flickr {
    
    // MARK: Properties
    
    static let shared = Flickr()
    var session = URLSession.shared
    
    // MARK: Methods
    
    func taskForGet(with parameters: [String : AnyObject], completion handler: @escaping (AnyObject?, NSError?) -> Void) {
        
        // Setup parameters
        var modifiedParameters = parameters
        modifiedParameters[Flickr.Constants.ParameterKeys.apiKey] = Flickr.Constants.ParameterValues.apiKey as AnyObject
        
        // Setup URL
        let url = makeURL(from: modifiedParameters)
        
        // Setup request
        let request = URLRequest(url: url!)
        
        // Setup task
        let task = session.dataTask(with: request) {
            data, response, error in
            
            func sendError(errorString: String) {
                let userInfo = [NSLocalizedDescriptionKey: errorString]
                let error = NSError(domain: "taskForGet", code: 1, userInfo: userInfo)
                handler(nil, error)
            }
            
            // Checking for errors
            guard error == nil else {
                sendError(errorString: "Error: \(error!.localizedDescription)")
                return
            }
            
            guard let data = data else {
                sendError(errorString: "Could not retrieve data.")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode < 300 else {
                sendError(errorString: "Invalid status code!")
                return
            }
            
            // Convert fetched data
            self.convert(data: data, completion: handler)
            
        }
        
        // Start task
        task.resume()
    }
    
}
