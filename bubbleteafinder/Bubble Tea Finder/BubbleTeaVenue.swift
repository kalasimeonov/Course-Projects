//
//  BubbleTeaVenue.swift
//  Bubble Tea Finder
//
//  Created by Kaloyan Simeonov on 13.07.20.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation

struct BubbleTeaVenue: Decodable {
  
  var response: Response?
  
  init(name: String, phone: String?, specialCount: Int, categoryId: String, categoryName: String, address: String?,
       city: String, country: String, distance: Double, state: String, zipcode: String?,
       priceCat: Int, checkinsCount: Int, tipCount: Int, usersCount: Int) {
    
    self.response?.venues[0].name = name
    self.response?.venues[0].contact!.phone = phone ?? nil
    self.response?.venues[0].specials.count = specialCount
    self.response?.venues[0].categories[0].id = categoryId
    self.response?.venues[0].categories[0].name = categoryName
    self.response?.venues[0].location.address = address
    self.response?.venues[0].location.city = city
    self.response?.venues[0].location.country = country
    self.response?.venues[0].location.distance = distance
    self.response?.venues[0].location.state = state
    self.response?.venues[0].location.postalCode = zipcode
    self.response?.venues[0].price.tier = priceCat
    self.response?.venues[0].stats.checkinsCount = checkinsCount
    self.response?.venues[0].stats.tipCount = tipCount
    self.response?.venues[0].stats.usersCount = usersCount
    
  }
}

struct Response: Decodable {
  var venues: [Venues]
}

struct Venues: Decodable {
  var name: String
  var contact: Contact?
  var specials: Specials
  var location: LocationInfo
  var categories: [Categories]
  var price: Price
  var stats: Statistics
}

struct Contact: Decodable {
  var phone: String?
}

struct Specials: Decodable {
  var count: Int
}

struct LocationInfo: Decodable {
  var address: String?
  var city: String
  var country: String
  var distance: Double
  var state: String
  var postalCode: String?
}

struct Categories: Decodable {
  var name: String
  var id: String
}
struct Price: Decodable {
  var tier: Int
}
struct Statistics: Decodable {
  var checkinsCount: Int
  var tipCount: Int
  var usersCount: Int
}

