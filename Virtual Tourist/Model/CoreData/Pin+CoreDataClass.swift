//
//  Pin+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by Cihan Turkay on 09.10.17.
//  Copyright © 2017 Cihan Turkay. All rights reserved.
//
//

import Foundation
import CoreData


public class Pin: NSManagedObject {

    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(_ latitude:Double, _ longitude:Double, _ page:Int16, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        super.init(entity: entity, insertInto: context)
        self.latitude = latitude
        self.longitude = longitude
        self.page = page
    }
    
}
