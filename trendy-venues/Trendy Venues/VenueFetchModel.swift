//
//  VenueModel.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//

import Foundation

struct VenueModel: Decodable {
    
    //MARK: -Properties
    var response: Response?
    
    //MARK: -CodingKey enums
    private enum MainKeys: CodingKey {
        case response
    }
    
    private enum ResponseKeys: CodingKey {
        case groups
        case headerLocation
    }
    
    private enum GroupKeys: CodingKey {
        case items
    }
    
    private enum VenueKeys: CodingKey {
        case name
        case location
    }
    
    private enum LocationKeys: CodingKey {
        case address
    }
    
    //MARK: -Data structures
    struct Response: Decodable {
        var headerLocation: String = "Unknown city"
        var groups: [Group]
    }
    
    struct Group: Decodable {
        var items: [Items]
    }
    
    struct Items: Decodable {
        var venue: Venue
    }
    
    struct Venue: Decodable {
        var name: String
        var location: Location
    }
    
    struct Location: Decodable {
        var address: String = "Address is not available"
    }
    
    init() {
    }
    
    //MARK: -Init
    init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: MainKeys.self) {
            self.response = try container.decode(Response.self, forKey: .response)
        }
        
    }
    
    
}
