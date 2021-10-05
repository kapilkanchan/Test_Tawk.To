//
//  Profile+CoreDataProperties.swift
//  
//
//  Created by Kapil Kanchan on 03/10/21.
//
//

import Foundation
import CoreData


extension Profile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Profile> {
        return NSFetchRequest<Profile>(entityName: "Profile")
    }

    @NSManaged public var login: String
    @NSManaged public var name: String?
    @NSManaged public var id: Int64
    @NSManaged public var notes: String?
    @NSManaged public var following: Int64
    @NSManaged public var followers: Int64
    @NSManaged public var company: String?
    @NSManaged public var blog: String?
    @NSManaged public var avatarUrl: String?

}
