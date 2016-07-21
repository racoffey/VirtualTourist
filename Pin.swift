//
//  Pin.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 07/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import CoreData


class Pin: NSManagedObject {

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

}
