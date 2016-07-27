//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 15/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //let stack = AppDelegate
    var pin : Pin? = nil
    //var pinName : String = ""
    //let context : NSManagedObjectContext? = nil
    
    //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
 //   let stack = delegate.stack
    var nextPinNumber : Int = 0
    
    // Get the stack

 //   var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(animated: Bool) {
        //super.viewWillAppear(true)
        
        // Restore earlier map position and size
        if NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") != nil {
            let mapPoint = MKMapPointMake((NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") as! Double), NSUserDefaults.standardUserDefaults().valueForKey("mapOriginY") as! Double)
            let mapSize = MKMapSize(width: (NSUserDefaults.standardUserDefaults().valueForKey("mapWidth") as! Double), height: (NSUserDefaults.standardUserDefaults().valueForKey("mapHeight") as! Double))
            let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
            mapView.setVisibleMapRect(mapRect, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        mapView.delegate = self
        activityIndicator.hidden = false
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(TravelLocationsMapViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)

        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //                      NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        //let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //let ip = NSIndexPath.init(index: 0)
        
        // Start the fetched results controller
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
        
        nextPinNumber = (fetchedResultsController.fetchedObjects?.count)! + 1

        print("Next Pin number in map View = \(nextPinNumber)")
        
        if fetchedResultsController.fetchedObjects != nil {
            for pin in fetchedResultsController.fetchedObjects as! [Pin] {
                print(pin.name)
                mapView.addAnnotation(pin)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        let originX = mapView.visibleMapRect.origin.x
        let originY = mapView.visibleMapRect.origin.y
        let mapWidth = mapView.visibleMapRect.size.width
        let mapHeight = mapView.visibleMapRect.size.height
        NSUserDefaults.standardUserDefaults().setValue(originX, forKey: "mapOriginX")
        NSUserDefaults.standardUserDefaults().setValue(originY, forKey: "mapOriginY")
        NSUserDefaults.standardUserDefaults().setValue(mapWidth, forKey: "mapWidth")
        NSUserDefaults.standardUserDefaults().setValue(mapHeight, forKey: "mapHeight")
        print("Saving map settings")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use Student Location as annotation object, create annotation view and assign queued annotations if possible
        //     if let annotation = annotation as? StudentLocation {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            //If queued annotations not availabel then create new with call out and accessory
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
     /*       view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -10, y: 10)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView */
        }
        view.canShowCallout = false
        //Return the annotation view
        return view
    }
    
    
/*    //If call out it tapped then open URL link in Student Location
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {
        //let annotation = view.annotation
        print("Call out was pressed")
        print("URL =  \(view.annotation?.subtitle)")
        //Check URL is properly formatted and if not present error on map
        if let url = NSURL(string: ((view.annotation?.subtitle)!)!) {
            print("Url being opened = \(url)")
            UIApplication.sharedApplication().openURL(url)
        }
        else {
            displayError("Cannot present web page")
        }
    }
*/
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Selected annotation = \(view.annotation?.title)")
        //pin = Pin(name: view.annotation!.title!!, latitude: (view.annotation?.coordinate.latitude)!, longitude: view.annotation!.coordinate.longitude, context: stack.context)
        
        pin = view.annotation as? Pin
        
       // pinName = (view.annotation?.title)!
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegueWithIdentifier("showPhotoAlbum", sender: self)
    }
    
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.hidden = true
    }
    
    func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        //gestureRecognizer.state
        print("Reached handleTap \(gestureRecognizer.state.hashValue)")
        if gestureRecognizer.state.hashValue == 1 {
            let location = gestureRecognizer.locationInView(mapView)
            let coordinate = mapView.convertPoint(location,toCoordinateFromView: mapView)
        
            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        

 /*       // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
 */
        // Create the pin in Core Data
        
            let pin = Pin(name: "pin \(nextPinNumber)", latitude: coordinate.latitude, longitude: coordinate.longitude, context: sharedContext)
            print("Just created a pin: \(pin.name)")
            nextPinNumber += 1
            CoreDataStackManager.sharedInstance().saveContext()
        
        }
    }
    
    
    //Present messages to user
    func displayError(error: String) {
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("Reached prepare for Segue")
        if segue.identifier! == "showPhotoAlbum"{
            
            if let photoAlbumVC = segue.destinationViewController as? PhotoAlbumViewController{
                
                // Create Fetch Request
                //let fr = NSFetchRequest(entityName: "Photo")
                
                //fr.sortDescriptors = [NSSortDescriptor(key: "date_taken", ascending: false),
                  //                    NSSortDescriptor(key: "title", ascending: true)]
                
                // So far we have a search that will match ALL notes. However, we're
                // only interested in those within the current notebook:
                // NSPredicate to the rescue!
    //            let indexPath = tableView.indexPathForSelectedRow!
    //            let pin = fetchedResultsController?.objectAtIndexPath(indexPath) as? Pin
                //let pin = fetchedResultsController
                
    //            let pred = NSPredicate(format: "pin = %@", argumentArray: [pin!])
                
    //            fr.predicate = pred
                
/*                // Get the stack
                let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                let stack = delegate.stack
 */
                // Create the FetchedResultsController
             /*  let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                                        managedObjectContext: sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    
                */
                // Inject it into the notesVC
             //   photoAlbumVC.fetchedResultsController = fetchedResultsController
                
                // Inject the notebook too!
                photoAlbumVC.pin = pin
                
            }
        }
    }
}

