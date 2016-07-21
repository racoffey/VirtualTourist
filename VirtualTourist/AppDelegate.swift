//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 02/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    let stack = CoreDataStack(modelName: "Model")!
    
    
    func preloadData(){
        
        // Remove previous stuff (if any)
        do{
            try stack.dropAllData()
        }catch{
            print("Error droping all objects in DB")
        }
        
 //       Pin(name: "New pin", context: self.stack.context)
        // Create notebooks
        let pin1 = Pin(name : "First pin", latitude: 0, longitude: 0, context: stack.context)
        let pin2  = Pin(name: "Second pin", latitude: 0, longitude: 0, context: stack.context)
        
        // Check out the "data" field when you print an NSManagedObject subclass.
        // It looks like a Dictionary and the values in it are called
        // _Modelled Properties_. These are the properties defined in the
        // Data Model. They reside in the SQLite DB
        print(pin1)
        print(pin2)
        
        // Create Notes
        let wwdc = Photo(title: "WWDC", url_m: "", context: stack.context)
        let kitura = Photo(title: "Learn about Kitura, a web framework in Swift by IBM", url_m: "", context: stack.context)
        
        // When you print any of these notes, you should notice that the notebook
        // relationship is nil. We explicitly forbid this in the Data Model, so
        // what's going on???
        // Core Data validations only kick in when you try to save a context, and
        // we haven't done that so far. If we try to save right now, we would get
        // a crash.
        print(wwdc)
        print(kitura)
        
        
        // Let's set the notebook property of those 2 notes
        wwdc.pin = pin1
        kitura.pin = pin2
        
        // Wait a minute! Should you also set the notes property in codeNotes?
        // NO! There's no need for that. Since we gave Core Data both relationships
        // (notes and notebook), whenever we make a change on one side, does the
        // appropriate change on the other one.
        // Play around with this, by adding a new note to codeNotes, remove it
        // and check if evertyhing is in sync.
        // See how Core data automates managing your model objects? :-)
        
        
    // Let's now add note to ideas
        let daDump = Photo(title: "daDump: social network for people using the toilet", url_m: "", context: stack.context)
        daDump.pin = pin1
   
        
        
        
    }
    
    
    
    func backgroundLoad(){
        
/*        stack.performBackgroundBatchOperation { (workerContext) in
            
            
            for i in 1...100{
                let pin = Pin(name: "Background notebook \(i)", context: workerContext)
                
                for _ in 1...100{
                    let photo = Photo(text: "The path of the righteous man is beset on all sides by the iniquities of the selfish and the tyranny of evil men. Blessed is he who, in the name of charity and good will, shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children. And I will strike down upon thee with great vengeance and furious anger those who would attempt to poison and destroy My brothers. And you will know My name is the Lord when I lay My vengeance upon thee.", context: workerContext)
                    photo.pin = pin
                }
            }
            print("==== finished background operation ====")
            
        } */
    }
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Load some notebooks and notes.
        preloadData()
        
        // Start Autosaving
        stack.autoSave(60)
        
        // add new objects in the background
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(5 * NSEC_PER_SEC)), dispatch_get_main_queue()){
            self.backgroundLoad()
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        stack.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        stack.save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

