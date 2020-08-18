//
//  VenueModel.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//

import Foundation

struct VenueCategory: Decodable {
    var response: Response
    
    struct Response: Decodable {
        var categories: [Category]
    }
    
    struct Category: Decodable {
        var name: String
    }
}

