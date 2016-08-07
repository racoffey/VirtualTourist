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
    
    let stackManager = CoreDataStackManager.sharedInstance()
    
    // App only supports portrait mode
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Start Autosaving when application launches
        stackManager.autoSave(60)

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        //Save CoreData when resigning active state
        stackManager.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        //Save CoreData when application entering background state
        stackManager.save()
    }

}

