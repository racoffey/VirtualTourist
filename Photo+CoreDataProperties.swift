//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 06/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var date_taken: NSDate?
    @NSManaged var image: NSData?
    @NSManaged var title: String?
    @NSManaged var url_m: String?
    @NSManaged var pin: Pin?

}
