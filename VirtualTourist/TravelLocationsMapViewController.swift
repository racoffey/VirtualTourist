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

// This view controller presents map on which users can place Pins.  When a Pin is selected the view will transition to the PhotoAlbumViewController where Photos related to the area of the selected Pin will be shown. Pins are stored in Core Data and are persistent.

class TravelLocationsMapViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    //Instantiate Pin object
    var pin : Pin? = nil
    
    //Instantiate the Core Data Stack manager and get context
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    // Pin counter for naming next pin
    var nextPinNumber : Int = 0
    

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Restore earlier map position and size from NSUserDefaults
        if NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") != nil {
            let mapPoint = MKMapPointMake((NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") as! Double), NSUserDefaults.standardUserDefaults().valueForKey("mapOriginY") as! Double)
            let mapSize = MKMapSize(width: (NSUserDefaults.standardUserDefaults().valueForKey("mapWidth") as! Double), height: (NSUserDefaults.standardUserDefaults().valueForKey("mapHeight") as! Double))
            let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
            mapView.setVisibleMapRect(mapRect, animated: true)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Add mapView delegate to controller
        mapView.delegate = self
        
        //Show activity indicator
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        // Add gesture recogniser for long press to trigger new pin and add delegate
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(TravelLocationsMapViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)
        

        // Start the Fetched Results Controller 
        fetchResults()
        
        // Update pin counter
        nextPinNumber = (fetchedResultsController.fetchedObjects?.count)! + 1

        // Add Pin annotations to map
        if fetchedResultsController.fetchedObjects != nil {
            for pin in fetchedResultsController.fetchedObjects as! [Pin] {
                mapView.addAnnotation(pin)
            }
        }
    }
    
    // Support only portrait mode
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    // Support only portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    //Save latest map coordinates and size to NSUserDefaults
    override func viewWillDisappear(animated: Bool) {
        let originX = mapView.visibleMapRect.origin.x
        let originY = mapView.visibleMapRect.origin.y
        let mapWidth = mapView.visibleMapRect.size.width
        let mapHeight = mapView.visibleMapRect.size.height
        NSUserDefaults.standardUserDefaults().setValue(originX, forKey: "mapOriginX")
        NSUserDefaults.standardUserDefaults().setValue(originY, forKey: "mapOriginY")
        NSUserDefaults.standardUserDefaults().setValue(mapWidth, forKey: "mapWidth")
        NSUserDefaults.standardUserDefaults().setValue(mapHeight, forKey: "mapHeight")
    }
    
    // Fetched results controller for Pin entities
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // Fetch results from Core Data and display any error
    func fetchResults() {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            displayError("Error fetching Pins from Core Data: \(error)")
        }
    }
}


extension TravelLocationsMapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use Pin as annotation object, create annotation view and assign queued annotations if possible
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            //If queued annotations not available then create new
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        // No Callout wanted
        view.canShowCallout = false

        //Return the annotation view
        return view
    }
    
    
    // Assign selected Pin annotation to pin variable for use in prepareForSegue and trigger segue to Photo View
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        pin = view.annotation as? Pin
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegueWithIdentifier("showPhotoAlbum", sender: self)
    }
    
    
    // Stop and hide activity indicator when map has rendered
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.stopAnimating()
    }
    
    // Handle long press on map gesture
    func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Get map coordinates of long press
        let location = gestureRecognizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
        
        // After long press and before releasing, the user can drag the pin around the map.  The follow switch statements support the movement for the pin and saving of pin object when user releases.
        switch gestureRecognizer.state {
        
        // Begins after long press
        case .Began:

            // Create the pin in Core Data
            pin = Pin(name: "pin \(nextPinNumber)", latitude: coordinate.latitude, longitude: coordinate.longitude, context: sharedContext)
            
            // Show new pin on the map
            mapView.addAnnotation(pin!)
            
            // Increment pin counter
            nextPinNumber += 1
        
        // Location of pin can be changed before users releases touch, by dragging the pin around the map
        case .Changed:
            // Update with new coordinates for the pin object
            pin!.setCoordinate(coordinate.latitude, longitude: coordinate.longitude)
            
            // Update pin location on the map
            mapView.removeAnnotation(pin!)
            mapView.addAnnotation(pin!)
            
        // Action finalised when user releases the pin
        case .Ended:
            
            // Pin object and map updated with final coordinates
            pin?.setCoordinate(coordinate.latitude, longitude: coordinate.longitude)
            mapView.removeAnnotation(pin!)
            mapView.addAnnotation(pin!)
            
            // New Pin changes saved to Core Data
            CoreDataStackManager.sharedInstance().save()
            
            // Download photos associated with the new pin location starts as soon as pin is placed
            getPhotos()
            
        default:
            return
        }
    }
    
    
    // Call on flickrClient shared instance to start downloading photos
    func getPhotos() {
        FlickrClient.sharedInstance().getPhotos(sharedContext, pin: pin!) { (success, errorString) in
            if success {
                return
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    
    // Inject selected Pin to the PhotoAlbumViewController before segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "showPhotoAlbum"{
            if let photoAlbumVC = segue.destinationViewController as? PhotoAlbumViewController{
                photoAlbumVC.pin = pin
                
            }
        }
    }
    
    
    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}

