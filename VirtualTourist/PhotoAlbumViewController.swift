//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 16/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

// The PhotoAlbumViewController presents photos associated with a given Pin.  Photos can be reloaed by selecting "New Collection" and deleted by clicked on them.

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Arrays to keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    // Outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Instantiate Pin
    var pin : Pin? = nil

    // Get context from shared instance from CoreDataStackManager
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    
    //Only support portrait mode
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    
    //Only support portrait mode
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        //Prepare activity indicator
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
        // Start the fetched results controller
        fetchResults()
        
        // If there are no Photo objects stored for this Pin get them, otherwise continue
        let count = (fetchedResultsController.fetchedObjects?.count)! as Int
        if count < 1 {
            print("Need to get photos!")
            getPhotos()
        } else {
            activityIndicator.stopAnimating()
            print("setPlaceHolder set as false")
        }
        
        // Add collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Add the collectionView
        self.view.addSubview(collectionView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Restore earlier map position and size
        if NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") != nil {
            let mapPoint = MKMapPointMake((NSUserDefaults.standardUserDefaults().valueForKey("mapOriginX") as! Double), NSUserDefaults.standardUserDefaults().valueForKey("mapOriginY") as! Double)
            let mapSize = MKMapSize(width: (NSUserDefaults.standardUserDefaults().valueForKey("mapWidth") as! Double)/4, height: (NSUserDefaults.standardUserDefaults().valueForKey("mapHeight") as! Double)/4)
            let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
            mapView.setVisibleMapRect(mapRect, animated: true)
            
            // Add Pin annotation for selected Pin
            if pin != nil {
                mapView.addAnnotation(pin!)
                mapView.setCenterCoordinate((pin?.coordinate)!, animated: true)
            }
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        // Lay out the collection view so that cells take up 1/3 of the width with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        print("Width = \(width)")
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    
    // Activate fetchedResultsController by performing fetch of photos related to the selected Pin
    func fetchResults () {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        if let error = error {
            displayError("Error performing fetch of photos: \(error)")
        }
    }
    

    // MARK: - UICollectionView
    
    // Get number of sections for collection view if available or return with 1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    
    // Get number of objects to be shown in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfObjects = (fetchedResultsController.fetchedObjects?.count)! as Int
        return numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        // Get the Photo for this indexPath
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        // Get the next cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
        // Configure image view
        let imageView = UIImageView(frame: CGRectMake(1, 1, collectionView.frame.size.width/3-1, collectionView.frame.size.width/3-1))
        //imageView.contentMode = .ScaleAspectFill
        
        // If Photo image available then use this, otherwise display the placeholder image
        if (photo.image != nil) {
            let image = UIImage(data: photo.image!)!
            imageView.image = image
        } else {
            let image = UIImage(named: "placeholder.png")
            imageView.image = image
        }
        
        // Add image view to cell and return
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Simply delete photos that are selected
        deleteSelectedPhotos(indexPath)
    }
    
    
    // Get fetchedResultsController for Photo selection based on selected Pin
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.sortDescriptors = []
        
        //Select only the photos for the give Pin
        print("Pin before predicate = \(self.pin)")
        let pred = NSPredicate(format: "pin = %@", argumentArray: [self.pin!])
        fetchRequest.predicate = pred
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    // CONTROLLER DELEGATE METHODS
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    
    // The second method may be called multiple times, once for each object that is added, deleted, or changed. We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            // Here we record that a new Photo instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .Delete:
            // Here we record that a Photo instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
            
        case .Update:
            // This records changes to Photos after they are created. This is needed for example, when an image is downloaded from Flickr
            updatedIndexPaths.append(indexPath!)
            break
            
        case .Move:
            // We don't expect items to move in this app.
            break
        default:
            break
        }
    }

    // This method is invoked after changes in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). Here we loop through the
    // arrays and perform the changes.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
                self.collectionView.reloadData()
                self.collectionView.reloadInputViews()
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }
    
    // ASSISTING FUNCTIONS
    
    // Delete all Photos in the collection when fetching a new collection
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
    }
    
    // Delete photo that is selected by user
    func deleteSelectedPhotos(indexPath: NSIndexPath) {
        let photoToDelete = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        sharedContext.deleteObject(photoToDelete)
        CoreDataStackManager.sharedInstance().save()
    }
    
    // Get photos using FlickrClient
    func getPhotos() {
        FlickrClient.sharedInstance().getPhotos(sharedContext, pin: pin!) { (success, errorString) in
            if success {
                self.collectionView.reloadData()
            } else {
                self.displayError(errorString!)
            }
            // Stop activity indictor and enable button when initial images are shown
            performUIUpdatesOnMain({
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.newCollectionButton.enabled = true
            })
        }
    }

    
    //Present message to user using Alert Controller
    func displayError(error: String) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // When newCollectionButton pressed, delete existing collection and download new collection. 
    // Acivity indicator is started and button disabled until initial images are shown.
    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        newCollectionButton.enabled = false
        
        // Delete current collection
        deleteAllPhotos()
        
        // Download new collection
        getPhotos()
    }
}


