//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Robert Coffey on 12/07/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import CoreData


// Flickr API client

class FlickrClient : NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()

    
    // Request photos related to Pin location from Flickr
    func getPhotos(context: NSManagedObjectContext, pin: Pin, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
    
        // General random page number between 1 and maxPages
        let page = Int(arc4random_uniform(Constants.General.maxPages) + 1)
        
        //Establish parameters for GET request
        let method = ""
        let parameters: [String: AnyObject] =
            [Constants.FlickrRequestKeys.ApiKey : Constants.FlickrRequestValues.ApiKey,
             Constants.FlickrRequestKeys.DataFormat : Constants.FlickrRequestValues.DataFormat,
             Constants.FlickrRequestKeys.Extras : Constants.FlickrRequestValues.Extras,
             Constants.FlickrRequestKeys.NoJsonCallBack : Constants.FlickrRequestValues.NoJsonCallBack,
             Constants.FlickrRequestKeys.PerPage : Constants.FlickrRequestValues.PerPage,
             Constants.FlickrRequestKeys.SafeSearch : Constants.FlickrRequestValues.SafeSearch,
             Constants.FlickrRequestKeys.Method : Constants.FlickrRequestValues.Method,
             Constants.FlickrRequestKeys.Latitude : pin.latitude!,
             Constants.FlickrRequestKeys.Longitude : pin.longitude!,
             Constants.FlickrRequestKeys.Page : page]
        
        
        //Execute GET method
        taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            // Handle error case
            if error != nil {
                completionHandlerForSession(success: false, errorString: "Failed to get photos. \(error)")
            } else {
                //Put results into a data object, extract photos into photoResults and then individual photos into Photos array
                var resultsDict = results as! [String: AnyObject]
                let photoResults = resultsDict["photos"] as! [String: AnyObject]
                let photosArray = photoResults["photo"] as! [AnyObject]
                if photosArray.endIndex == 0 {
                    completionHandlerForSession(success: false, errorString: "No photos are available for this location!")
                }
                
                // Create Core Data Photo object for each photo in array in memory
                for item in photosArray {
                    let dict = item as! [String: AnyObject]

                    let photo = Photo(title: dict["title"] as! String, url_m: dict["url_m"] as! String, context: context)
                    
                    // Define parent Pin in Photo object
                    photo.pin = pin
                    
                    // Download images on background thread and update Core Data Photo object when downloaded
                    performUIUpdatesOnBackground({
                        if let url  = NSURL(string: photo.url_m!),
                            data = NSData(contentsOfURL: url)
                        {
                            photo.image = data
                        }
                    })
                 }
                
                // Save changes to Core Data
                CoreDataStackManager.sharedInstance().save()
                
                // Successfully complete session
                completionHandlerForSession(success: true, errorString: nil)
            }
        }
    }
    
    
    
    // GET method
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Construct the URL request using input parameters
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))

        //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print("Error : \(error)")
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            //Was there an error?
            guard (error == nil) else {
                sendError("The HTTP GET request failed. Check network connection!")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                //self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGET)
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data and return the result
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // Execute the request
        task.resume()
        
        return task
    }
    

    // Assisting functions
    
    // Create JSON string based on parameters dictionary
    func covertToJson (parameters: [String: AnyObject]) -> String {
        var jsonBody: String = "{"
        var newValue: String
        for (key, value) in parameters {
            print("Key = \(key)")
            print("Value = \(value)")
            if value is Double {
                newValue = String(value)
                let string: String = ("\"\(key)\": \(newValue), ")
                jsonBody.appendContentsOf(string)
            }
            else {
                newValue = value as! String
                let string: String = ("\"\(key)\": \"\(newValue)\", ")
                jsonBody.appendContentsOf(string)
            }
        }
        //Last comma and space removed and brace added
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.removeAtIndex(jsonBody.endIndex.predecessor())
        jsonBody.appendContentsOf("}")
        return jsonBody
    }
    
    
    // Create a URL from parameters
    func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.URL!
    }
 
    
    // Parse raw JSON to NS object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsedResult: AnyObject?
        
        //Attempt to parse data and report error if failure
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON"]
            completionHandlerForConvertData(result: nil, error: NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        // Return parsed result
        completionHandlerForConvertData(result: parsedResult, error: nil)
    }
    
    
    // Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}