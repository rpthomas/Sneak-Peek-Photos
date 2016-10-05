//
//  Invites+CoreDataProperties.swift
//  Sneak Peek Photos
//
//  Created by Roland Thomas on 7/2/16.
//  Copyright © 2016 Jedisware, LLC. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Invites {

    @NSManaged var inviteId: String?
    @NSManaged var userId: String?
    @NSManaged var recipientEmail: String?
    @NSManaged var txtInviteKey: String?
    @NSManaged var txtInviteCount: String?
    @NSManaged var txtInvitePhone: String?
    @NSManaged var isActive: NSNumber?
    @NSManaged var picId: String?

}
