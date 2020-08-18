//
//  CoreDataStack.swift
//  PetPal
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {

    lazy var managedContext: NSManagedObjectContext = {
      return self.storeContainer.viewContext
    }()

    private lazy var storeContainer: NSPersistentContainer = {
      
      let container = NSPersistentContainer(name: "PetPal")
      container.loadPersistentStores { (storeDescription, error) in
        if let error = error as NSError? {
          print("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return container
    }()
    
    func saveContext () {
      guard managedContext.hasChanges else { return }

      do {
        try managedContext.save()
      } catch {
        let nserror = error as NSError
        print("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
}

  

