//
//  WeatherManager.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 22.06.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: [WeatherModel], daily: Bool)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    
    let baseURL = "https://api.openweathermap.org/data/2.5/"
    
    let dailyWeatherURL = "weather?appid=97ef9d07dda770e6afe3d447b2866190&units=metric"
    
    let hourWeatherURL = "forecast?appid=97ef9d07dda770e6afe3d447b2866190&cnt=5&units=metric&fbclid=IwAR32NU0osgv-RTwJ-Y15QlXieCK3IzWHbqx6IlUCNX6Iz_8Cj3MV-7zazNI"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let dailyUrlString = "\(baseURL)\(dailyWeatherURL)&q=\(cityName)"
        let hourUrlString = "\(baseURL)\(hourWeatherURL)&q=\(cityName)"
        performDailyRequest(urlString: dailyUrlString)
        performHourRequest(urlString: hourUrlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let dailyUrlString = "\(baseURL)\(dailyWeatherURL)&lat=\(latitude)&lon=\(longitude)"
        let hourUrlString = "\(baseURL)\(hourWeatherURL)&lat=\(latitude)&lon=\(longitude)"
        performDailyRequest(urlString: dailyUrlString)
        performHourRequest(urlString: hourUrlString)
    }
    
    func performDailyRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseDailyJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: [weather], daily: true)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    func performHourRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseHourJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather, daily: false)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseDailyJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(DailyWeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let name = decodedData.name
            
            let dailyWeather = WeatherModel(conditionId: id, cityName: name, temperature: temperature, date: nil, weekday: nil, hour: nil)
            return dailyWeather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func parseHourJSON(weatherData: Data) -> [WeatherModel]? {
        let decoder = JSONDecoder()
        do {
            var dailyWeather: [WeatherModel] = []
            
            let decodedData = try decoder.decode(HourWeatherData.self, from: weatherData)
            
            decodedData.list.forEach {
                let id = $0.weather[0].id
                let temp = $0.main.temp
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
                let rawDate = formatter.date(from: $0.dt_txt)
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "MMM dd"
                let date = dateFormat.string(from: rawDate!)
                dateFormat.dateFormat = "HH:mm"
                let hour = dateFormat.string(from: rawDate!)
                let components = Calendar.current.dateComponents(in: .current, from: rawDate!)
                let weekday = returnWeekday(for: components.weekday!)
                let weather = WeatherModel(conditionId: id, cityName: nil, temperature: temp, date: date, weekday: weekday, hour: hour)
                dailyWeather.append(weather)
            }
            
            return dailyWeather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    func returnWeekday(for index: Int) -> String {
        switch index {
        case 1:
            return "Sunday"
        case 2:
           return "Monday"
        case 3:
            return "Tuesday"
        case 4:
            return "Wednesday"
        case 5:
            return "Thursday"
        case 6:
            return "Friday"
        case 7:
            return "Saturday"
        default:
            return "Not a day of the week"
        }
    }
    
}
