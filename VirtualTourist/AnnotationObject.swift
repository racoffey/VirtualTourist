//
//  AnnotationObject.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 10/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import MapKit

// Class to meet MKAnnotation protocol requirements for map annotation
class AnnotationObject: NSObject, MKAnnotation {
    
    //Parameters
    var coordinate: CLLocationCoordinate2D
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var name: String
    
    init(pin: Pin) {
        self.latitude = pin.latitude as! CLLocationDegrees
        self.longitude = pin.longitude as! CLLocationDegrees
        self.name = pin.name!
        coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        
        super.init()
    }
    
    // Name and URL variables can be called according to the MKAnnotation protocol
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return ""
    }
}