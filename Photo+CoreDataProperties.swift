//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 07/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Photo {

    @NSManaged var title: String?
    @NSManaged var url_m: String?
    @NSManaged var image: NSData?
    @NSManaged var date_taken: NSDate?
    @NSManaged var text: String?
    @NSManaged var id: String?
    @NSManaged var owner: String?
    @NSManaged var secret: String?
    @NSManaged var server: NSNumber?
    @NSManaged var farm: NSNumber?
    @NSManaged var geo: String?
    @NSManaged var pin: Pin?

}
