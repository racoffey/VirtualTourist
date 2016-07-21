//
//  PinViewController.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 06/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PinsViewController: CoreDataTableViewController {
    
    
    @IBAction func addNewPin(sender: AnyObject) {
        
        // Create a new notebook... and Core Data takes care of the rest!
        let pin = Pin(name: "New Pin", latitude: 0, longitude: 0,
                          context: fetchedResultsController!.managedObjectContext)
        print("Just created a pin: \(pin)")
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        // Set the title
        title = "PinViewController"
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true),
                              NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
 
        let number = fetchedResultsController?.fetchedObjects?.count
        print("Fetched results = \(number)")
        
 /*       FlickrClient.sharedInstance().getPhotos((fetchedResultsController?.managedObjectContext)!) { (success, errorString) in
            
        }
  */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:  - TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        // This method must be implemented by our subclass. There's no way
        // CoreDataTableViewController can know what type of cell we want to
        // use.
        
        
        // Find the right notebook for this indexpath
        let pin = fetchedResultsController!.objectAtIndexPath(indexPath) as! Pin
        
        
        
        // Create the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("PinCell", forIndexPath: indexPath)
        
        // Sync notebook -> cell
        cell.textLabel?.text = pin.name
        cell.detailTextLabel?.text = String(format: "%d photos", pin.photos!.count)
        
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if let context = fetchedResultsController?.managedObjectContext,
            pin = fetchedResultsController?.objectAtIndexPath(indexPath) as? Pin
            where editingStyle == .Delete{
            
            context.deleteObject(pin)
            
        }
        
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Reached prepare for Segue")
        if segue.identifier! == "displayPhotos"{
            
            if let photosVC = segue.destinationViewController as? PhotosViewController{
                
                // Create Fetch Request
                let fr = NSFetchRequest(entityName: "Photo")
                
                fr.sortDescriptors = [NSSortDescriptor(key: "date_taken", ascending: false),
                                      NSSortDescriptor(key: "title", ascending: true)]
                
                // So far we have a search that will match ALL notes. However, we're
                // only interested in those within the current notebook:
                // NSPredicate to the rescue!
                let indexPath = tableView.indexPathForSelectedRow!
                let pin = fetchedResultsController?.objectAtIndexPath(indexPath) as? Pin
                
                let pred = NSPredicate(format: "pin = %@", argumentArray: [pin!])
                
                fr.predicate = pred
                
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fr,
                                                    managedObjectContext:fetchedResultsController!.managedObjectContext,
                                                    sectionNameKeyPath: "humanReadableAge",
                                                    cacheName: nil)
                
                // Inject it into the notesVC
                photosVC.fetchedResultsController = fc
                
                // Inject the notebook too!
                photosVC.pin = pin
                
            }
        }
        
/*       if segue.identifier! == "segueToMap" {
        if let mapVC = segue.destinationViewController as? TravelLocationsMapViewController{
            let mapVC.stack = 
        }
        }*/
    }
}
