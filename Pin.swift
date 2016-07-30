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
            self.page = 1
            
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