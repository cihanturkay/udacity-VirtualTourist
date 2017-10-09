//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 09.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

extension FlickerClient {
    
    // MARK: Flickr
    struct Constant {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let PerPage = "per_page"
        static let Page = "page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let APIKey = "9c39072239b96f659038e63f1783193d"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let PerPage = 20
        static let SearchPhotoMethod = "flickr.photos.search"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}

