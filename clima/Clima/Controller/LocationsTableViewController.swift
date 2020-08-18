//
//  LocationsTableViewController.swift
//  Clima
//
//  Created by Kaloyan Simeonov on 25.06.20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit

protocol LocationsDelegate {
    func didSelectLocation(with cityName: String)
}

class LocationsTableViewController: UITableViewController {
    
    //MARK: -Outlets
    @IBOutlet var locationsTableView: UITableView!
    
    //MARK: -Properties
    var locations: [WeatherModel] = Storage.fileExists("locations.json", in: .documents) ? Storage.retrieve("locations.json", from: .documents, as: [WeatherModel].self) : []
    
    var location: WeatherModel?
    var delegate: LocationsDelegate?
}

// MARK: - Table view data source
extension LocationsTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        cell.cityNameLabel.text = locations[indexPath.row].cityName
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        locations.remove(at: indexPath.row)
        locationsTableView.deleteRows(at: [indexPath], with: .automatic)
        Storage.remove("locations.json", from: .documents)
        Storage.store(locations, to: .documents, as: "locations.json")
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = locationsTableView.frame.height / 8
        return height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cityName = locations[indexPath.row].cityName!
        delegate?.didSelectLocation(with: cityName)
        dismiss(animated: true, completion: nil)
    }


}
