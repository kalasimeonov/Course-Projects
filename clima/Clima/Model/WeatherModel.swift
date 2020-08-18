//
//  WeatherModel.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 22.06.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel : Codable {
    
    let conditionId: Int
    let cityName: String?
    let temperature: Double
    let date: String?
    let weekday: String?
    let hour: String?
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt.fill"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain.fill" 
        case 600...622:
            return "cloud.snow.fill"
        case 700...781:
            return "cloud.fog"
        case 801...804:
            return "cloud.fill"
        case 800:
            return "sun.max"
        default:
            return "wind"
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(conditionId: Int, cityName: String?, temperature: Double, date: String?, weekday: String?, hour: String?) {
        self.conditionId = conditionId
        self.cityName = cityName
        self.temperature = temperature
        self.date = date
        self.weekday = weekday
        self.hour = hour
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(WeatherModel.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
}
