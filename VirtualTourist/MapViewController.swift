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

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        mapView.delegate = self
        activityIndicator.hidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension MapViewController: MKMapViewDelegate, UIGestureRecognizerDelegate {
    
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
        //Return the annotation view
        return view
        //    }
        //    return nil
    }
    
    //If call out it tapped then open URL link in Student Location
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
                 calloutAccessoryControlTapped control: UIControl!) {
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
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.hidden = true
    }
    
    func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        
        let location = gestureReconizer.locationInView(mapView)
        let coordinate = mapView.convertPoint(location,toCoordinateFromView: mapView)
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
    //Present messages to user
    func displayError(error: String) {
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

