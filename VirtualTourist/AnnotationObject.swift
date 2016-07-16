//
//  AnnotationObject.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 10/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit
/*
// Class to meet MKAnnotation protocol requirements for map annotation
class AnnotationObject: NSObject, MKAnnotation {
    
    //Parameters
    var coordinate: CLLocationCoordinate2D
    var firstName: String
    var lastName: String
    var mediaURL: String
    
    init(pin: Pin) {
        self.coordinate = pin.latitude
        self.firstName = pin.longitude
        self.lastName = pin.name
        self.mediaURL = pin.mediaURL!
        
        super.init()
    }
    
    // Name and URL variables can be called according to the MKAnnotation protocol
    var title: String? {
        return firstName + " " + lastName
    }
    
    var subtitle: String? {
        return mediaURL
    }
}*/