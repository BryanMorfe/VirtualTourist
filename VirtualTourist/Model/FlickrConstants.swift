//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import Foundation

// MARK: Flickr Constants

extension Flickr {
    
    struct Constants {
        
        struct URL {
            static let scheme = "https"
            static let host = "api.flickr.com"
            static let path = "/services/rest"
        }
        
        struct Methods {
            static let searchMethod = "flickr.photos.search"
        }
        
        struct ParameterKeys {
            static let apiKey = "api_key"
            static let method = "method"
            static let boundingBox = "bbox"
            static let extras = "extras"
            static let responseFormat = "format"
            static let perPage = "per_page"
            static let noJSONCallback = "nojsoncallback"
            static let safeSearch = "safe_search"
            static let page = "page"
        }
        
        struct ParameterValues {
            static let apiKey = "ac36abeaa2a114c7e82a971af0820899"
            static let mediumURL = "url_m"
            static let jsonFormat = "json"
            static let disableJSONCallback = "1"
            static let enableSafeSearch = "1"
            static let perPage = 30
        }
        
        struct JSONResponseKeys {
            static let mediumURL = "url_m"
            static let photos = "photos"
            static let photo = "photo"
            static let title = "title"
            static let total = "total"
            static let perPage = "perpage"
            static let pages = "pages"
        }
        
    }
    
}
