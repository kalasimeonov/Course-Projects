//
//  VenueProvider.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 15.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//
import Foundation
import CoreLocation

protocol VenueProviderDelegate {
    func didUpdateCity(_ recommendations: [VenueModel])
    func didFailWithError(error: Error)
}

struct VenueProvider {
    
    private let baseURL = "https://api.foursquare.com/v2/venues/explore?client_id=\(Constants.clientID)&client_secret=\(Constants.clientSecret)&v=\(Constants.version)"
    var delegate: VenueProviderDelegate?
    
    func getVenues(in cityName: String) {
        let cityVenuesURL = "\(baseURL)&near=\(cityName)"
        performRequest(urlString: cityVenuesURL)
    }
    
    func getVenues(at latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let cityVenuesURL = "\(baseURL)&ll=\(latitude),\(longitude)"
        performRequest(urlString: cityVenuesURL)
    }
    
    private func performRequest(urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    switch self.parseJSON(venuesData: safeData) {
                    case .success(let venues):
                        self.delegate?.didUpdateCity(venues)
                    case .failure(let error):
                        self.delegate?.didFailWithError(error: error)
                    }
                }
            }
            task.resume()
        }
        
    }
    
    private func parseJSON(venuesData: Data) -> Result<[VenueModel], GetVenuesError> {
        let decoder = JSONDecoder()
        do {
            var recommendedVenues: [VenueModel] = []
            let data = try decoder.decode(VenueModel.self, from: venuesData)
            if let response = data.response {
                response.groups[0].items.forEach({ (venue) in
                    var recommendedVenue = VenueModel()
                    recommendedVenue.response = response
                    recommendedVenue.response?.headerLocation = data.response?.headerLocation ?? ""
                    recommendedVenue.response?.groups[0].items[0] = venue
                    recommendedVenues.append(recommendedVenue)
                })
            }
            return .success(recommendedVenues)
        } catch let error {
            return .failure(.parsingDataError(error))
        }
    }
    
}

enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
}

enum GetVenuesError: Error {
     case parsingDataError(Error)
}


struct Constants {
    static let clientID = "QPH3SOVGXRTZ13ZR0VE5ZUZMZXKCKBGZZ30W31BZCQKIYRJX"
    static let clientSecret = "PDFFQHJPHTKPFOGOI1ODR11CQWAE0QQS10FCDOOVXXNM0GSO"
    static let version = "20120609"
}
