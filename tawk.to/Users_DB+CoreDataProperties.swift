//
//  Users_DB+CoreDataProperties.swift
//  
//
//  Created by Kapil Kanchan on 03/10/21.
//
//

import Foundation
import CoreData


extension Users_DB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Users_DB> {
        return NSFetchRequest<Users_DB>(entityName: "Users_DB")
    }

    @NSManaged public var avatarUrl: String?
    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var user_profile: Profile?
}
