
//
//  Photo.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 07/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import CoreData
import UIKit


class Photo: NSManagedObject {
    
    
    //Initiate instance include EntityDescription object
    convenience init(title: String, url_m: String, context: NSManagedObjectContext){
        
        if let ent = NSEntityDescription.entityForName("Photo",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.title = title
            self.url_m = url_m
            self.date_taken = NSDate()
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
}