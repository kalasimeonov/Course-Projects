//
//  WeatherData.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 22.06.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct DailyWeatherData: Codable {
    let name: String
    let main: Temperature
    let weather: [WeatherCondition]
    
}

struct Temperature: Codable {
    let temp: Double
}

struct WeatherCondition: Codable {
    let id: Int
}

