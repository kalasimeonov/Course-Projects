//
//  DataImporter.swift
//  Bubble Tea Finder
//
//  Created by Kaloyan Simeonov on 13.07.20.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation
import CoreData

class DataImporter {
  
  init(coreDataStack: CoreDataStack) {
    self.coreDataStack = coreDataStack
  }
  
  var coreDataStack: CoreDataStack!
  
  func importJSONSeedDataIfNeeded() {
    
    let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
    let count = try! coreDataStack.managedContext.count(for: fetchRequest)
    
    guard count == 0 else { return }
    
    do {
      let results = try coreDataStack.managedContext.fetch(fetchRequest)
      results.forEach({ coreDataStack.managedContext.delete($0) })
      
      coreDataStack.saveContext()
      importJSONSeedData()
    } catch let error as NSError {
      print("Error fetching: \(error), \(error.userInfo)")
    }
  }
  
  func importJSONSeedData() {
    let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
    let jsonData = NSData(contentsOf: jsonURL)! as Data
    let bubbleTeaVenues = parseJSON(venueData: jsonData)
    
    let venueEntity = NSEntityDescription.entity(forEntityName: "Venue", in: coreDataStack.managedContext)!
    let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: coreDataStack.managedContext)!
    let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: coreDataStack.managedContext)!
    let priceEntity = NSEntityDescription.entity(forEntityName: "PriceInfo", in: coreDataStack.managedContext)!
    let statsEntity = NSEntityDescription.entity(forEntityName: "Stats", in: coreDataStack.managedContext)!
    
    bubbleTeaVenues.response?.venues.forEach { venue in
      //MARK: -Location
      let location = Location(entity: locationEntity, insertInto: coreDataStack.managedContext)
      let locationData = venue.location
      location.address = locationData.address
      location.city = locationData.city
      location.country = locationData.country
      location.distance = Float(exactly: locationData.distance)!
      location.state = locationData.state
      location.zipcode = locationData.postalCode
      
      //MARK: -Category
      let category = Category(entity: categoryEntity, insertInto: coreDataStack.managedContext)
      let categoryData = venue.categories[0]
      category.categoryID = categoryData.id
      category.name = categoryData.name
      
      //MARK: -Price info
      let priceInfo = PriceInfo(entity: priceEntity, insertInto: coreDataStack.managedContext)
      let priceData = venue.price
      priceInfo.priceCategory = String(priceData.tier)
      
      //MARK: -Stats
      let stats = Stats(entity: statsEntity, insertInto: coreDataStack.managedContext)
      let statsData = venue.stats
      stats.checkinsCount = Int32(exactly: (statsData.checkinsCount) as NSNumber)!
      stats.tipCount = Int32(exactly: (statsData.tipCount) as NSNumber)!
      stats.usersCount = Int32(exactly: (statsData.usersCount) as NSNumber)!
      
      //MARK: -Adding the entity
      let venueEntity = Venue(entity: venueEntity, insertInto: coreDataStack.managedContext)
      venueEntity.favorite = true
      
      let name = venue.name
      let phone = venue.contact?.phone
      let specialCount = venue.specials.count as NSNumber
      
      venueEntity.name = name
      venueEntity.phone = phone
      venueEntity.specialCount = Int32(exactly: specialCount)!
      venueEntity.category = category
      venueEntity.location = location
      venueEntity.priceInfo = priceInfo
      venueEntity.stats = stats
    }
    
    coreDataStack.saveContext()
  }
  
  func parseJSON(venueData: Data) -> BubbleTeaVenue {
    let decoder = JSONDecoder()
    do {
      var bubbleTeaVenue: BubbleTeaVenue?
      
      let decodedData = try decoder.decode(BubbleTeaVenue.self, from: venueData)
      
      decodedData.response?.venues.forEach {
        let name = $0.name
        let phone = $0.contact?.phone
        let specialCount = $0.specials.count
        let categoryId = $0.categories[0].id
        let categoryName = $0.categories[0].name
        let address = $0.location.address
        let city = $0.location.city
        let country = $0.location.country
        let distance = $0.location.distance
        let state = $0.location.state
        let zipcode = $0.location.postalCode
        let priceCat = $0.price.tier
        let checkinsCount = $0.stats.checkinsCount
        let tipCount = $0.stats.tipCount
        let usersCount = $0.stats.usersCount
        
        var venue = BubbleTeaVenue(name: name, phone: phone, specialCount: specialCount, categoryId: categoryId, categoryName: categoryName, address: address, city: city, country: country, distance: distance, state: state, zipcode: zipcode ?? nil, priceCat: priceCat, checkinsCount: checkinsCount, tipCount: tipCount, usersCount: usersCount)
        venue.response = decodedData.response
        bubbleTeaVenue = venue
      }
      return bubbleTeaVenue!
    } catch let error {
      fatalError("Couldn't parse json data: \(error)")
    }
  }
}
