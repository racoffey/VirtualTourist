//
//  Constants.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 10/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

import UIKit
import MapKit

// Constants

struct Constants {
    
    // Core data model constants
    struct CDModel {
        static let SQLFileName = "model"
    }
    
    // Flickr URL API parameters
    struct Flickr {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
    }
    
    
    // Flickr Response Keys
    struct FlickrResponseKeys {
        static let StatusCode = "status"
        static let ErrorMessage = "error"
        static let Results = "results"
        static let PhotoId = "id"
        static let Owner = "owner"
        static let Secret = "secret"
        static let DateTaken = "date_taken"
        static let Farm = "farm"
        static let Server = "server"
    }
    
    // Flickr request keys
    struct FlickrRequestKeys {
        static let ApiKey = "api_key"
        static let DataFormat = "format"
        static let NoJsonCallBack = "nojsoncallback"
        static let Extras = "extras"
        static let SafeSearch = "safe_search"
        static let PerPage = "per_page"
        static let BoundingBox = "bbox"
        static let Method = "method"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
    }
    
    // Flickr request values
    struct FlickrRequestValues {
        static let ApiKey = "74fdb9d81f8d5607a0b4a8dfa5be538e"
        static let DataFormat = "json"
        static let NoJsonCallBack = "1"
        static let Extras = "url_m,date_taken"
        static let SafeSearch = "1"
        static let PerPage = "10"
        static let Method = "flickr.photos.search"
    
    }
    
    
    // UI attriutes
    struct UI {
        static let LoginColorTop = UIColor(red: 0.900, green: 0.300, blue: 0.100, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.8, green: 0.5, blue: 0.3, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    // Selectors
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }
    
    // Map attributes
    struct Map {
        static let RegionRadius: CLLocationDistance  = 1000000
    }
    
}