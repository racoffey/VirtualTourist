//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 21/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//


import Foundation
import CoreData

//The CoreDataStackManager contains all the code needed to made the Core Data Stack

class CoreDataStackManager {
    
    // Properties
    let model : NSManagedObjectModel
    var coordinator : NSPersistentStoreCoordinator?
    let directoryURL : NSURL
    let modelURL : NSURL
    let dbURL : NSURL
    let context : NSManagedObjectContext
    
    // Shared Instance
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance!
    }
    
    init?() {
        
        // Instantiating the application directory property
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        self.directoryURL = urls[urls.count-1]
 
        //Instantiating the Managed Object Model property
        self.modelURL = NSBundle.mainBundle().URLForResource(Constants.CDModel.ModelName, withExtension: "momd")!
        self.model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        //Instantiating the persistant Store Coordinator and adding SQL Lite DB
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.dbURL = directoryURL.URLByAppendingPathComponent(Constants.CDModel.SQLFileName)
        var error: NSError? = nil
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        } catch let error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Model", code: 9999, userInfo: dict as! [NSObject : AnyObject])
            abort()
        } catch {
            fatalError()
        }
        
        //Instantiating the Managed Object Context property and connecting it to the coordinator
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        
   }
}

extension CoreDataStackManager  {
    
    // Store coordinator added
    func addStoreCoordinator(storeType: String,
                             configuration: String?,
                             storeURL: NSURL,
                             options : [NSObject : AnyObject]?) throws{
        
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        
    }
    
    
    func save() {
        // Saves main context synchronosly
        context.performBlockAndWait(){
            
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
            }
        }
    }
    
    // Autosave function which is called by AppDelegate
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
            
        }
    }
}