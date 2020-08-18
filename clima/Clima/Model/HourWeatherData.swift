//
//  HourWeatherData.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 23.06.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct HourWeatherData: Codable {
    let list: [WeatherItem]
    
    struct WeatherItem: Codable {
        let dt_txt: String
        let main: Temperature
        let weather: [WeatherCondition]
    }

}


