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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // The selected indexes array keeps all of the indexPaths for cells that are "selected". The array is
    // used inside cellForItemAtIndexPath to lower the alpha of selected cells.  You can see how the array
    // works by searchign through the code for 'selectedIndexes'
    var selectedIndexes = [NSIndexPath]()
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!

    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pin : Pin? = nil
    
    //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        print("Initial pin page = \(pin!.page)")
        
        // Start the fetched results controller
        fetchResults()
        
        let count = (fetchedResultsController.fetchedObjects?.count)! as Int
        
        print("Fetched results in photo album view = \(count)")
        
        if count < 1 {
            print("Need to get photos!")
            getPhotos()
        } else {
            activityIndicator.stopAnimating()
            print("setPlaceHolder set as false")
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
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
            if pin != nil {
                mapView.addAnnotation(pin!)
                mapView.setCenterCoordinate((pin?.coordinate)!, animated: true)
            }
            //setPlaceholders = false
            //self.registerClass(PhotoCell.self, forCellWithReuseIdentifier: Constants.CellReuseIdentifier)
            //self.registerClass(PhotoCell.self, forCellWithReuseIdentifier: Constants.PlaceholderCellReuseIdentifier)

        }
    }
    

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        // Lay out the collection view so that cells take up 1/3 of the width,
        // with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        print("Width = \(width)")
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
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
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCell, atIndexPath indexPath: NSIndexPath) {
        
        //let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        cell.color = UIColor.blackColor()
        
        // If the cell is "selected" it's color panel is grayed out
        // we use the Swift `find` function to see if the indexPath is in the array
 
/*        if let index = selectedIndexes.indexOf(indexPath) {
            cell.colourPanel.alpha = 0.05
        } else {
            cell.colourPanel.alpha = 1.0
        }*/
    }
    
    
    
    
    // MARK: - UICollectionView
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        print ("Number of sections = \(fetchedResultsController.sections?.count)")
        return self.fetchedResultsController.sections?.count ?? 1
        //let numberOfSections: Int = 1
        //return numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //let sectionInfo = self.fetchedResultsController.sections![section]
        // Start the fetched results controller
/*        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            print("Error performing initial fetch: \(error)")
        }
 
        fetchResults()
 */

        let numberOfObjects = (fetchedResultsController.fetchedObjects?.count)! as Int
        print("number Of Cells: \(numberOfObjects)")
        return numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        print("Reached cell for Item at Index Path: \(indexPath)")
        // Get the note
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell
        
/*        if setPlaceholders {
            print("setPlaceholder true and being placed")
            let imageView = UIImageView(frame: CGRectMake(1, 1, collectionView.frame.size.width/3-1, collectionView.frame.size.width/3-1))
            let image = UIImage(named: "placeholder.png")
            //imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            cell.contentView.addSubview(imageView)
            print("Placeholder cell added for indexpath: \(indexPath)")
            if indexPath.length == 12 {
                setPlaceholders = false
                print("Index path = 12 so setting setPlaceholder to false")
            }
        } else {
  */
        print("Photo to add = \(photo.title) at indexpath: \(indexPath)" )
        //cell.delete(self)
        
        let imageView = UIImageView(frame: CGRectMake(0, 0, collectionView.frame.size.width/3-2, collectionView.frame.size.width/3-2))
        
        if (photo.image != nil) {
            
            let image = UIImage(data: photo.image!)!
            //let image = UIImage(contentsOfFile: "default-placeholder.png")
            //let image = UIImage(named: "placeholder.png")
            
            //imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            cell.contentView.addSubview(imageView)
            print("Added image for \(photo.title)")
        } else {
            let image = UIImage(named: "placeholder-2.png")
            imageView.image = image
            cell.contentView.addSubview(imageView)
            print("Added placeholder for \(indexPath)")
        }
        
        //self.configureCell(cell, atIndexPath: indexPath)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        print("Reached did selection item at index path")
        
        deleteSelectedPhotos(indexPath)
        
  /*      let cell = collectionView.cellForItemAtIndexPath(indexPath) as! PhotoCell
        
        // Whenever a cell is tapped we will toggle its presence in the selectedIndexes array
        if let index = selectedIndexes.indexOf(indexPath) {
            selectedIndexes.removeAtIndex(index)
        } else {
            selectedIndexes.append(indexPath)
        }
 
        // Then reconfigure the cell
        configureCell(cell, atIndexPath: indexPath)
        
        // And update the buttom button
      //  updateBottomButton() */
    }


    
    // MARK: - NSFetchedResultsController
    
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
    
    // MARK: - Fetched Results Controller Delegate
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    
    // The second method may be called multiple times, once for each Color object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)

            break
        case .Delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .Update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an images is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .Move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }

    // This method is invoked after all of the changed in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
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
        
        fetchResults()
        print("Fetching results")
        collectionView.reloadData()
        print("Reloading data in DidChangeContent")
        collectionView.reloadInputViews()
    }
    
    func deleteAllPhotos() {
        
        for photo in fetchedResultsController.fetchedObjects as! [Photo] {
            sharedContext.deleteObject(photo)
        }
    }
    
    func deleteSelectedPhotos(indexPath: NSIndexPath) {
        print("Reached delete selected photos at \(indexPath)")
        var photosToDelete = [Photo]()
        
        //for indexPath in selectedIndexes {
            photosToDelete.append(fetchedResultsController.objectAtIndexPath(indexPath) as! Photo)
        //}
        
        for photo in photosToDelete {
            sharedContext.deleteObject(photo)
            CoreDataStackManager.sharedInstance().save()
        }
        
       // selectedIndexes = [NSIndexPath]()
    }
    
    func getPhotos() {
        let page = getPage()
        print("Getting photos with pin: \(pin!) and page: \(page)" )
        FlickrClient.sharedInstance().getPhotos(sharedContext, pin: pin!, page: page) { (success, errorString) in
            print("Returned from FlickrClient")
            if success {
                self.collectionView.reloadData()
                print("Data reloaded in getPhotos")
                //performUIUpdatesOnMain {
                //}
                print("Activity indicator stopped")
            } else {
                self.displayError(errorString!)
            }
            performUIUpdatesOnMain({
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                self.newCollectionButton.enabled = true
            })
        }

    }
    
    func getPage() -> Int {
          let pageNumber = Int(arc4random_uniform(100) + 1)
        return pageNumber
    }
    
    //Present message to user
    func displayError(error: String) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
        
        // Ensure UI is fully enabled again
        //   setUIEnabled(true)
    }
    
    

    @IBAction func newCollectionButtonPressed(sender: AnyObject) {
        print("New collection button pressed")
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        newCollectionButton.enabled = false
        deleteAllPhotos()
        //CoreDataStackManager.sharedInstance().saveContext()
        getPhotos()
        //collectionView.reloadData()
        print("Data reloaded")
    }
}


