//
//  ViewController.swift
//  Trendy Venues
//
//  Created by Kaloyan Simeonov on 16.07.20.
//  Copyright © 2020 Kaloyan Simeonov. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import SystemConfiguration

class VenuesViewController: UIViewController {
    
    //MARK: -IBOutlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var venuesTableView: UITableView!
    
    //MARK: -Properties
    private var coreDataStack = CoreDataStack.shared
    private var venuesProvider = VenueProvider()
    private var locationProvider = LocationProvider()
    private var currentCity: String?
    private var venues: [VenueModel] = [] {
        didSet {
            DispatchQueue.main.async {
                self.venuesTableView.reloadData()
            }
        }
    }
    private var lastVenues: [VenueModel] = []
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    //MARK: -Additional Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        venuesProvider.delegate = self
        locationProvider.delegate = self
        searchBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated) 
        venues = coreDataStack.fetchExistingVenues(for: currentCity)
    }
    
    //MARK: -IBActions
    @IBAction func locationPressed(_ sender: UIButton? = nil) {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.locationProvider.requestLocation()
        coreDataStack.saveLastVenues(in: lastVenues)
    }
    
}

//MARK: -UISearchBarDelegate
extension VenuesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let city = searchBar.text {
            self.view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            self.venuesProvider.getVenues(in: city)
        }
        
        searchBar.text = ""
        searchBar.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}

//MARK: -UITableViewDataSource
extension VenuesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = venues[indexPath.row].response?.groups[0].items[0].venue.name
        cell.detailTextLabel?.text = venues[indexPath.row].response?.groups[0].items[0].venue.location.address
        
        return cell
    }
    
}
//MARK: -UITableViewDelegate
extension VenuesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = self.view.frame.height / (6.0 as CGFloat)
        return height
    }
}

//MARK: -LocationManagerDelegate
extension VenuesViewController: LocationManagerDelegate {
    
    func didRequestLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        venuesProvider.getVenues(at: lat, longitude: lon)
    }
    
}

//MARK: -VenueProviderDelegate
extension VenuesViewController: VenueProviderDelegate {
    
    func didUpdateCity(_ recommendations: [VenueModel]) {
        venues.removeAll()
        for index in recommendations.indices where index < 5 {
            venues.append(recommendations[index])
            let venue = Venue(entity: Venue.entity(), insertInto: coreDataStack.managedContext)
            venue.city = recommendations[index].response?.headerLocation
            venue.name = recommendations[index].response?.groups[0].items[0].venue.name
            venue.address = recommendations[index].response?.groups[0].items[0].venue.location.address
            coreDataStack.saveContext()
        }
        lastVenues = venues
        DispatchQueue.main.async {
            self.activityIndicator.removeFromSuperview()
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            self.activityIndicator.removeFromSuperview()
            let alert = UIAlertController(title: "Alert", message: "The city you are looking for was not found, or you have no access to the internet! Please make sure the spelling is correct!", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
}

