//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 09.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//
//

import Foundation
import CoreData


public class Photo: NSManagedObject {

    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext, pin:Pin) {
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        self.url = dictionary[FlickerClient.FlickrResponseKeys.MediumURL] as? String
        self.pin = pin
        
    }
    
    static func photosFromResult(_ results: [[String:AnyObject]],  context: NSManagedObjectContext, _ pin: Pin) -> [Photo] {
        
        var photos = [Photo]()
        
        for result in results {
            photos.append(Photo.init(dictionary: result, context: context , pin: pin))
        }
        
        return photos
    }
}
