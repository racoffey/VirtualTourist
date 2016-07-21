//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 07/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PhotosViewController: CoreDataTableViewController {
    
    var pin : Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:  - TableView Data Source
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get the note
        let photo = fetchedResultsController?.objectAtIndexPath(indexPath) as! Photo
        
        // Get the cell
        let cell = tableView.dequeueReusableCellWithIdentifier("Photo", forIndexPath: indexPath)
        
        // Sync note -> cell
        cell.textLabel?.text = photo.title
        
 /*       performUIUpdatesOnBackground(){
        if let url  = NSURL(string: photo.url_m!),
            data = NSData(contentsOfURL: url)
        {
            cell.imageView!.image = UIImage(data: data)
        }
        }
*/
        if (photo.image != nil) {
            cell.imageView!.image = UIImage(data: photo.image!)
        }
        
        
        // Return the cell
        return cell
    }
    
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                                               forRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if let context = fetchedResultsController?.managedObjectContext,
            photo  = fetchedResultsController?.objectAtIndexPath(indexPath) as? Photo
            where editingStyle == .Delete{
            
            context.deleteObject(photo)
            
        }
    }
    
    
    
    @IBAction func addNewNote(sender: AnyObject) {
        
        if let pn = pin, context = fetchedResultsController?.managedObjectContext{
            
            // Just create a new note and you're done!
            let photo = Photo(title: "New Photo", url_m: "", context: context)
            photo.pin = pn
            
        }
        
        
    }
    
    
    // MARK:  - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showPhoto" {
            
            
            // Get the note
            // Get the detailVC
            
            if let ip = tableView.indexPathForSelectedRow,
                photo = fetchedResultsController?.objectAtIndexPath(ip) as? Photo,
                vc = segue.destinationViewController as? PhotoViewController{
                
                // Inject the note in the the detailVC
                vc.model = photo
                
            }
            
        }
    }
}
