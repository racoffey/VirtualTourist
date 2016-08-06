
//
//  Pin.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 30/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import CoreData
import MapKit

// Pin object that shall be placed in the map and stored in Core Data
class Pin: NSManagedObject, MKAnnotation {
    
    //Initiate Pin object including Entity Description
    convenience init(name: String, latitude: Double, longitude: Double, context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Pin",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
            self.creationDate = NSDate()
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
    
    // Meet MKAnnotation protocol requirements to provide title and coordinate for object.
    var title: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2DMake(self.latitude as! CLLocationDegrees, self.longitude as! CLLocationDegrees)
        return coordinate
    }
    
    // Function to support change of coordinates when dragging the Pin before it is dropped
    func setCoordinate(latitude: Double, longitude: Double) {
        willChangeValueForKey("latitude")
        self.latitude = latitude
        didChangeValueForKey("latitude")
        
        willChangeValueForKey("longitude")
        self.longitude = longitude
        didChangeValueForKey("longitude")
    }
}
