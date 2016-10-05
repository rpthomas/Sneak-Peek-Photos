//
//  Images+CoreDataProperties.swift
//  Sneak Peek Photos
//
//  Created by Roland Thomas on 5/31/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Images {

    @NSManaged var picId: String
    @NSManaged var imgId: String
    @NSManaged var imgDescr: String
    @NSManaged var img: NSData

}
