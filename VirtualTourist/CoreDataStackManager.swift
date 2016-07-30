//
//  CoreDataStackManager.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 21/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//


import Foundation
import CoreData

/**
 * The CoreDataStackManager contains the code that was previously living in the
 * AppDelegate in Lesson 3. Apple puts the code in the AppDelegate in many of their
 * Xcode templates. But they put it in a convenience class like this in sample code
 * like the "Earthquakes" project.
 *
 */

//private let SQLITE_FILE_NAME = "ModelCollection.sqlite"



class CoreDataStackManager {
    
    // MARK:  - Properties
    let model : NSManagedObjectModel
    var coordinator : NSPersistentStoreCoordinator?
    let directoryURL : NSURL
    let modelURL : NSURL
    let dbURL : NSURL
    let persistingContext : NSManagedObjectContext
    let backgroundContext : NSManagedObjectContext
    let context : NSManagedObjectContext
    
    // MARK: - Shared Instance
    
    /**
     *  This class variable provides an easy way to get access
     *  to a shared instance of the CoreDataStackManager class.
     */
    class func sharedInstance() -> CoreDataStackManager {
        struct Static {
            static let instance = CoreDataStackManager()
        }
        
        return Static.instance!
    }
    
    init?() {
        
        
        print("Instantiating the application directory property")
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        self.directoryURL = urls[urls.count-1]
 
        print("Instantiating the Managed Object Model property")
        self.modelURL = NSBundle.mainBundle().URLForResource(Constants.CDModel.ModelName, withExtension: "momd")!
        self.model = NSManagedObjectModel(contentsOfURL: modelURL)!
        
        print("Instantiating the persistant Store Coordinator and adding SQL Lite DB")
        self.coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        self.dbURL = directoryURL.URLByAppendingPathComponent(Constants.CDModel.SQLFileName)
        print("sqlite path: \(dbURL.path!)")
        var error: NSError? = nil
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Model", code: 9999, userInfo: dict as! [NSObject : AnyObject])
            
            // Left in for development development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        
        print("Instantiating the Managed Object Context property, inclding persistent and background contexts")
        
        // Create a persistingContext (private queue) and a child one (main queue)
        // create a context and add connect it to the coordinator
        persistingContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        persistingContext.persistentStoreCoordinator = coordinator
        
        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        context.parentContext = persistingContext
        
        // Create a background context child of main context
        backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        backgroundContext.parentContext = context

/*
        do {
            self.context = NSManagedObjectContext()
            context.persistentStoreCoordinator = coordinator
        } catch {
            print("Error: Not able to instaniate ManagedObjectContext as coordinator = nil")
            return nil
        }
*/    }
    
/*    func addPersistentStore() {
        var error: NSError? = nil
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Model", code: 9999, userInfo: dict as! [NSObject : AnyObject])
            
            // Left in for development development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
    }
*/
/*    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    
    lazy var applicationDocumentsDirectory: NSURL = {
        
        print("Instantiating the applicationDocumentsDirectory property")
        
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
*/
/*    lazy var getManagedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        
        print("Instantiating the managedObjectModel property")
        
        let modelURL = NSBundle.mainBundle().URLForResource(Constants.CDModel.ModelName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
*/
    /**
     * The Persistent Store Coordinator is an object that the Context uses to interact with the underlying file system. Usually
     * the persistent store coordinator object uses an SQLite database file to save the managed objects. But it is possible to
     * configure it to use XML or other formats.
     *
     * Typically you will construct your persistent store manager exactly like this. It needs two pieces of information in order
     * to be set up:
     *
     * - The path to the sqlite file that will be used. Usually in the documents directory
     * - A configured Managed Object Model. See the next property for details.
     */
    
/*    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        
        print("Instantiating the persistentStoreCoordinator property")
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.model)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(Constants.CDModel.SQLFileName)
        
        print("sqlite path: \(url.path!)")
        
        var error: NSError? = nil
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch var error1 as NSError {
            error = error1
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = "There was an error creating or loading the application's saved data."
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "Model Collection", code: 9999, userInfo: dict as! [NSObject : AnyObject])
            
            // Left in for development development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        } catch {
            fatalError()
        }
        
        return coordinator
    }()*/
 /*
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        print("Instantiating the managedObjectContext property")
        
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

*/





    // MARK: - Core Data Saving support

/*    func saveContext () {
        print("Reached save context")
  //      if let context != nil {
            
        var error: NSError? = nil
            
        if context.hasChanges {
            do {
                print("Context has changes and saving context")
                try context.save()
            } catch let error1 as NSError {
                error = error1
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
 */
}

extension CoreDataStackManager  {
    
    func dropAllData() throws{
        // delete all the objects in the db. This won't delete the files, it will
        // just leave empty tables.
        try coordinator!.destroyPersistentStoreAtURL(dbURL, withType:NSSQLiteStoreType , options: nil)
        
        try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
        
        
    }
    
    // MARK:  - Utils
    func addStoreCoordinator(storeType: String,
                             configuration: String?,
                             storeURL: NSURL,
                             options : [NSObject : AnyObject]?) throws{
        
        try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: dbURL, options: nil)
        
    }
    
    typealias Batch=(workerContext: NSManagedObjectContext) -> ()
    
    func performBackgroundBatchOperation(batch: Batch){
        
        backgroundContext.performBlock(){
            batch(workerContext: self.backgroundContext)
            
            // Save it to the parent context, so normal saving
            // can work
            do{
                try self.backgroundContext.save()
            }catch{
                fatalError("Error while saving backgroundContext: \(error)")
            }
        }
    }
    
    func save() {
        // We call this synchronously, but it's a very fast
        // operation (it doesn't hit the disk). We need to know
        // when it ends so we can call the next save (on the persisting
        // context). This last one might take some time and is done
        // in a background queue
        print("Saving")
        context.performBlockAndWait(){
            
            if self.context.hasChanges{
                do{
                    try self.context.save()
                }catch{
                    fatalError("Error while saving main context: \(error)")
                }
                
                // now we save in the background
                self.persistingContext.performBlock(){
                    do{
                        try self.persistingContext.save()
                    }catch{
                        fatalError("Error while saving persisting context: \(error)")
                    }
                }
                
                
            }
        }
    }
    
    func autoSave(delayInSeconds : Int){
        
        if delayInSeconds > 0 {
            print("Autosaving")
            save()
            
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInNanoSeconds))
            
            dispatch_after(time, dispatch_get_main_queue(), {
                self.autoSave(delayInSeconds)
            })
            
        }
    }
}