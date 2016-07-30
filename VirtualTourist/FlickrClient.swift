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


// Parse API client

class FlickrClient : NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()
   // let pin : Pin?
    
   // let stack = CoreDataStack(modelName: "Model")!
   // let p = Pin(name: "Hello", context: stack.context)
    
   // if let context = fetchedResultsController?.managedObjectContext{
        
        // Just create a new note and you're done!
   //     let pin = Pin(text: "New Note", context: fetchedResultsController?,managedObjectContext)
        //note.notebook = nb
        
   // }
    
    // Initializers
    
    override init() {
        //AppData.sharedInstance().photos = []
        super.init()
    }
    
    
    // Get a number of the last student locations
    func getPhotos(context: NSManagedObjectContext, pin: Pin, page: Int, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
    
        
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
        
        //If student locations have already been fetched, no need to fetch again unless specific refresh requested
        /*       if AppData.sharedInstance().hasFetchedStudentLocations {
         completionHandlerForSession(success: true, studentLocations: AppData.sharedInstance().studentLocations, errorString: nil)
         return
         }*/
        
        //Execute GET method
        taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            // Handle error case
            if error != nil {
                completionHandlerForSession(success: false, errorString: "Failed to get student locations. \(error)")
            } else {
                //Put results into a data object and extract each student location into the Student Locations array and return array
                //AppData.sharedInstance().photos.removeAll()
                var resultsDict = results as! [String: AnyObject]
                let photoResults = resultsDict["photos"] as! [String: AnyObject]
                let photosArray = photoResults["photo"] as! [AnyObject]

                for item in photosArray {
                    let dict = item as! [String: AnyObject]
                    //let photo = dict["title"] as! String

                    let photo = Photo(title: dict["title"] as! String, url_m: dict["url_m"] as! String, context: context)
                    if let url  = NSURL(string: photo.url_m!),
                        data = NSData(contentsOfURL: url)
                    {
                        photo.image = data
                    }
                    
                    photo.pin = pin
                    
                    print("Photo being saved to Core Data: \(photo.title)")
                 }
                CoreDataStackManager.sharedInstance().saveContext()
                 /*AppData.sharedInstance().hasFetchedStudentLocations = true
                 completionHandlerForSession(success: true, studentLocations: AppData.sharedInstance().studentLocations, errorString: nil)*/
            }
        }
    }
    
    
    // GET method
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Construct the URL request using input parameters
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        print (request)

        
        //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            print("Data: \(data)")
            print("Response: \(response)")
            
            func sendError(error: String) {
                print("Error : \(error)")
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            //Was there an error?
            guard (error == nil) else {
                sendError("The parse GET request failed.")
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
    
/*
    // POST method
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        // Build the URL based on header parameter and json body input
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterKeys.ApiKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        // Prepare request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("The POST method failed. \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your POST request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the POST request!")
                return
            }
            
            
            // Parse the data and return the resulting data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        //Initiate the request
        task.resume()
        
        return task
    }
    
    
    
    func postStudentLocation(bodyParameters: [String: AnyObject], completionHandlerForPostSL: (success: Bool, errorString: String?) -> Void) {
        
        //Prepare input parameters to POST request
        let parameters: [String: AnyObject] = [:]
        let method = "/StudentLocation"
        let jsonBody = covertToJson(bodyParameters)
        
        // Prepare request task using parameters
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            //Handle error case
            if let error = error {
                print(error.localizedDescription)
                completionHandlerForPostSL(success: false, errorString: error.localizedDescription)
            } else {
                //If no error then report back that request successfully executed
                completionHandlerForPostSL(success: true, errorString: nil)
            }
        }
    }
    
*/
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
    
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}