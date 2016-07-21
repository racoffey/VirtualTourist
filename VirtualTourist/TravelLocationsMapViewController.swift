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
    let pin : Pin? = nil
    //let context : NSManagedObjectContext? = nil

    var sharedContext = CoreDataStackManager.sharedInstance().managedObjectContext!
    
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
        
        // Load pins from core data
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        

        
        mapView.delegate = self
        activityIndicator.hidden = false
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(TravelLocationsMapViewController.handleTap(_:)))
        gestureRecognizer.delegate = self
        mapView.addGestureRecognizer(gestureRecognizer)

        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create a fetchrequest
        let fr = NSFetchRequest(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        //                      NSSortDescriptor(key: "creationDate", ascending: false)]
        
        // Create the FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fr,
                                                              managedObjectContext: stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
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
        
        let pin = fetchedResultsController.fetchedObjects?.count

        print("Fetched results in map View = \(pin)")
        
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
        /*        print("Saved X = \(originX)")
         print("Saved Y = \(originY)")
         print("Saved width = \(mapWidth)")
         print("Saved height = \(mapHeight)") */
        NSUserDefaults.standardUserDefaults().setValue(originX, forKey: "mapOriginX")
        NSUserDefaults.standardUserDefaults().setValue(originY, forKey: "mapOriginY")
        NSUserDefaults.standardUserDefaults().setValue(mapWidth, forKey: "mapWidth")
        NSUserDefaults.standardUserDefaults().setValue(mapHeight, forKey: "mapHeight")
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
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -10, y: 10)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        view.canShowCallout = false
        //Return the annotation view
        return view
        //    }
        //    return nil
    }
    
    
    //If call out it tapped then open URL link in Student Location
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
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        print("Did select annotation")
        mapView.deselectAnnotation(view.annotation, animated: true)
        
    }
    
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.hidden = true
 /*       let originX = mapView.visibleMapRect.origin.x
        let originY = mapView.visibleMapRect.origin.y
        let mapWidth = mapView.visibleMapRect.size.width
        let mapHeight = mapView.visibleMapRect.size.height
/*        print("Saved X = \(originX)")
        print("Saved Y = \(originY)")
        print("Saved width = \(mapWidth)")
        print("Saved height = \(mapHeight)") */
        NSUserDefaults.standardUserDefaults().setValue(originX, forKey: "mapOriginX")
        NSUserDefaults.standardUserDefaults().setValue(originY, forKey: "mapOriginY")
        NSUserDefaults.standardUserDefaults().setValue(mapWidth, forKey: "mapWidth")
        NSUserDefaults.standardUserDefaults().setValue(mapHeight, forKey: "mapHeight")*/
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(location,toCoordinateFromView: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        
        // Get the stack
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let stack = delegate.stack
        
        // Create the pin in Core Data
        let pin = Pin(name: "New Pin from map", latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
        print("Just created a pin: \(pin)")
        
        //Get the photos
        let fc = FlickrClient.sharedInstance()
        fc.getPhotos(stack.context, pin: pin) { (success, errorString) in
            print("Photos being retrieved")
        }
        
        
    }
    
    
    //Present messages to user
    func displayError(error: String) {
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

