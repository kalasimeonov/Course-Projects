//
//  Venue+CoreDataProperties.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 17.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//
//

import Foundation
import CoreData


extension Venue {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Venue> {
        return NSFetchRequest<Venue>(entityName: "Venue")
    }

    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var city: String?

}
