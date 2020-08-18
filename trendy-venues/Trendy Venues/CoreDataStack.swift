//
//  CoreDataStack.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private var fetchedRC: NSFetchedResultsController<Venue>!
    
    lazy var managedContext: NSManagedObjectContext = {
      return self.persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Trendy_Venues")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteAllVenues() {
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Venue")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchReq)
        
        do {
            try managedContext.execute(deleteRequest)
        } catch let error {
            print(error)
        }
    }
    
    private func add(venue: VenueModel, context: NSManagedObjectContext) {
        let venueEntity = Venue(entity: Venue.entity(), insertInto: context)
        venueEntity.name = venue.response?.groups[0].items[0].venue.name
        venueEntity.address = venue.response?.groups[0].items[0].venue.location.address
        venueEntity.city = venue.response?.headerLocation
        saveContext()
    }
    
    func retrieveVenues() -> [VenueModel] {
        var venues: [VenueModel] = []
        if let objects = fetchedRC.fetchedObjects {
            objects.forEach( { (venueObject) in
                var venue = VenueModel()
                venue.response?.groups[0].items[0].venue.name = venueObject.name!
                venue.response?.groups[0].items[0].venue.location.address = venueObject.address!
                venue.response?.headerLocation = venueObject.city!
                venues.append(venue)
            })
        }
        return venues
    }
    
    func fetchExistingVenues(for currentCity: String?) -> [VenueModel] {
        let request = Venue.fetchRequest() as NSFetchRequest<Venue>
        let sort = NSSortDescriptor(key: #keyPath(Venue.name), ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        request.returnsDistinctResults = true
        request.sortDescriptors = [sort]
        request.fetchLimit = 5
        if let city = currentCity {
            request.predicate = NSPredicate(format: "city CONTAINS[cd] %@", city)
        }
        do {
            fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
            try fetchedRC.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return retrieveVenues()
    }
    
    func saveLastVenues(in venues: [VenueModel]) {
        deleteAllVenues()
        venues.forEach { (venue) in
            add(venue: venue, context: managedContext)
        }
    }
    
    private init() {}
}
