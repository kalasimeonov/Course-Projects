//
//  LocationManager.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 1.07.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//
import Foundation
import CoreLocation

protocol LocationManagerDelegate {
    func didRequestLocation(lat: CLLocationDegrees, lon: CLLocationDegrees)
}

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    var delegate: LocationManagerDelegate?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            manager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            delegate?.didRequestLocation(lat: lat, lon: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        fatalError("\(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            requestLocation()
        } else {
            requestAccess()
        }
    }
    
    func requestLocation() {
        manager.requestLocation()
    }
    
    func requestAccess() {
        manager.requestWhenInUseAuthorization()
    }
    
    override init() {
        super.init()
        self.manager.delegate = self
    }
}
