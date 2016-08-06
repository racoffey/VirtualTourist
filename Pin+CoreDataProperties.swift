//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 05/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Pin {

    @NSManaged var creationDate: NSDate?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var name: String?
    @NSManaged var photos: NSSet?

}
