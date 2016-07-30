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
 */

//
//  Pin.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 07/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//
/*
import Foundation
import CoreData
import MapKit


class Pin: NSManagedObject, MKAnnotation {
    
    // Insert code here to add functionality to your managed object subclass
    
    convenience init(name: String, latitude: Double, longitude: Double, context: NSManagedObjectContext){
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entityForName("Pin",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = name;
            self.latitude = latitude
            self.longitude = longitude
            
            print("Reached Pin")
            self.creationDate = NSDate()
        }else{
            fatalError("Unable to find Entity name!")
        }
        
    }
    
    var title: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2DMake(self.latitude as! CLLocationDegrees, self.longitude as! CLLocationDegrees)
        return coordinate
    }
    
}
 */