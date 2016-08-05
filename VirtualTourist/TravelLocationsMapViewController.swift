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
    
    var pin : Pin? = nil
    
    var sharedContext = CoreDataStackManager.sharedInstance().context 
    
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
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(TravelLocationsMapViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        

        // Start the fetched results controller

        fetchResults()
        
        nextPinNumber = (fetchedResultsController.fetchedObjects?.count)! + 1

        print("Next Pin number in map View = \(nextPinNumber)")
        
        if fetchedResultsController.fetchedObjects != nil {
            for pin in fetchedResultsController.fetchedObjects as! [Pin] {
                print(pin.name)
                mapView.addAnnotation(pin)
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
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
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    func fetchResults() {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use Student Location as annotation object, create annotation view and assign queued annotations if possible
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            //If queued annotations not available then create new with call out and accessory
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        view.canShowCallout = false
        view.draggable = true
        //Return the annotation view
        return view
    }
    
    
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Selected annotation = \(view.annotation?.title)")
        //pin = Pin(name: view.annotation!.title!!, latitude: (view.annotation?.coordinate.latitude)!, longitude: view.annotation!.coordinate.longitude, context: stack.context)
        
        pin = view.annotation as? Pin
        
       // pinName = (view.annotation?.title)!
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegueWithIdentifier("showPhotoAlbum", sender: self)
    }
    
    
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.stopAnimating()
    }
    
    func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        //gestureRecognizer.state
        var annotationToBeAdded: Pin? = nil
        print("Reached handleTap \(gestureRecognizer.state.hashValue)")
        var location = gestureRecognizer.locationInView(mapView)
        var coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
        
        switch gestureRecognizer.state {
        case .Began:
            print("began gesture state")
//            annotationToBeAdded = Annotation()
//            annotationToBeAdded.setCoordinate(newCoordinates)
//            mapView.addAnnotation(annotation)
//            let pin = Pin(entity: coordinate, insertIntoManagedObjectContext: self.sharedContext)
            
            // Create the pin in Core Data
            pin = Pin(name: "pin \(nextPinNumber)", latitude: coordinate.latitude, longitude: coordinate.longitude, context: sharedContext)
            print("Just created a pin: \(pin!.name)")
            
            mapView.addAnnotation(pin!)
            nextPinNumber += 1
            
        case .Changed:
            print("changed gesture state")
            pin!.setCoordinate(coordinate.latitude, longitude: coordinate.longitude)
            mapView.removeAnnotation(pin!)
            mapView.addAnnotation(pin!)
            
            
        case .Ended:
            print("ended gesture state")
            pin?.setCoordinate(coordinate.latitude, longitude: coordinate.longitude)
            mapView.removeAnnotation(pin!)
            mapView.addAnnotation(pin!)
            CoreDataStackManager.sharedInstance().save()
            // Download images as soon as pin is placed
            getPhotos()
            
        default:
            return
        }
    }
    
        
        
/*
        let annotationView = pin as! MKAnnotation
        switch gestureRecognizer.state.hashValue {
        case 1:
            pin?.
        }
        if gestureRecognizer.state.hashValue == 3 {

            let coordinate = mapView.convertPoint(location,toCoordinateFromView: mapView)
        
/*            // Add annotation:
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        
*/
        // Create the pin in Core Data
            pin = Pin(name: "pin \(nextPinNumber)", latitude: coordinate.latitude, longitude: coordinate.longitude, context: sharedContext)
            print("Just created a pin: \(pin!.name)")
        
            // Add annotation to map
            mapView.addAnnotation(pin!)
            nextPinNumber += 1
            CoreDataStackManager.sharedInstance().save()
            
            // Download images as soon as pin is placed
            getPhotos()
        }
    }*/
    
    func getPhotos() {
        let page = 1
        print("Getting photos from Travel Location View Controller with pin: \(pin!) and page: \(page)" )
        FlickrClient.sharedInstance().getPhotos(sharedContext, pin: pin!, page: page) { (success, errorString) in
            if success {
                return
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    
    
    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
        
        // Ensure UI is fully enabled again
     //   setUIEnabled(true)
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

