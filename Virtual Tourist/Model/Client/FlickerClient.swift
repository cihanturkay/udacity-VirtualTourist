//
//  FlickerClient.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 09.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//

import Foundation
import UIKit

class FlickerClient: NSObject {
    
    let stack = (UIApplication.shared.delegate as! AppDelegate).stack
    var session = URLSession.shared
    
    override init() {
        super.init()
    }
    
    
    // MARK: GET STUDENT LOCATIONS
    
    func getImagesFromFlicker(_ pin:Pin, _ completionHandler: @escaping (_ photos: [Photo]?, _ error: NSError?) -> Void) {
        
        let parameters = [
            FlickerClient.FlickrParameterKeys.Method: FlickerClient.FlickrParameterValues.SearchPhotoMethod,
            FlickerClient.FlickrParameterKeys.APIKey: FlickerClient.FlickrParameterValues.APIKey,
            FlickerClient.FlickrParameterKeys.Extras: FlickerClient.FlickrParameterValues.MediumURL,
            FlickerClient.FlickrParameterKeys.Format: FlickerClient.FlickrParameterValues.ResponseFormat,
            FlickerClient.FlickrParameterKeys.NoJSONCallback: FlickerClient.FlickrParameterValues.DisableJSONCallback,
            FlickerClient.FlickrParameterKeys.PerPage : FlickerClient.FlickrParameterValues.PerPage,
            FlickerClient.FlickrParameterKeys.Latitude : pin.latitude,
            FlickerClient.FlickrParameterKeys.Longitude : pin.longitude,
            FlickerClient.FlickrParameterKeys.Page : pin.page
            ] as [String : AnyObject]
        
        let request = NSMutableURLRequest(url: urlFromParameters(parameters))
        
        let _ = runRequest(request as URLRequest) { (results, error) in
            if let error = error {
                print(error)
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            } else {
                if let photos = results?[FlickerClient.FlickrResponseKeys.Photos] as? [String:AnyObject], let photoArray = photos[FlickerClient.FlickrResponseKeys.Photo] as? [[String:AnyObject]] {
                    let flickerPhotoList = Photo.photosFromResult(photoArray, context: self.stack.context, pin)
                    DispatchQueue.main.async {
                       completionHandler(flickerPhotoList, error)
                    }
                } else {
                    print("Couldn't parse locations")
                    DispatchQueue.main.async {
                        completionHandler(nil, NSError(domain: "getStudentLocations parsing", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                    }
                }
            }
        }
    }
    
    private func runRequest(_ request: URLRequest, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        /* Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(error!.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandler)
        }
        
        task.resume()
        
        return task
    }
    
    private func urlFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = FlickerClient.Constant.ApiScheme
        components.host = FlickerClient.Constant.ApiHost
        components.path = FlickerClient.Constant.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        print("url \(String(describing: components.url))")
        
        return components.url!
    }
    
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    class func sharedInstance() -> FlickerClient {
        struct Singleton {
            static var sharedInstance = FlickerClient()
        }
        return Singleton.sharedInstance
    }
}
