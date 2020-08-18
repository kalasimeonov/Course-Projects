//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: -Outlets
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar! 
    @IBOutlet weak var degreesSignLabel: UILabel!
    @IBOutlet weak var saveLocationLabel: UIButton!{
        didSet{
            saveLocationLabel.layer.cornerRadius = 7.0
        }
    }
    @IBOutlet weak var savedLocationsLabel: UIButton!{
        didSet{
            savedLocationsLabel.layer.cornerRadius = 7.0
        }
    }
    @IBOutlet weak var hourWeatherTableView: UITableView!
    
    //MARK: -Properties
    private var weatherManager = WeatherManager()
    var locationManager = LocationManager()
    private var hourWeather: [WeatherModel]? {
        didSet {
            hourWeatherTableView.reloadData()
        }
    }
    var weatherLocation: WeatherModel = WeatherModel(conditionId: 801, cityName: "Bali", temperature: 30.0, date: nil, weekday: nil, hour: nil)
    var savedLocations: [WeatherModel] = {
        if Storage.fileExists("locations.json", in: .documents) {
            return Storage.retrieve("locations.json", from: .documents, as: [WeatherModel].self)
        } else {
            return []
        }
    }()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    
    //MARK: -Additional setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hourWeatherTableView.dataSource = self
        hourWeatherTableView.delegate = self
        locationManager.delegate = self
        locationManager.requestAccess()

        weatherManager.delegate = self
        searchBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSavedLocations" {
            let destinationVC: UINavigationController = segue.destination as! UINavigationController
            let locationsVC = destinationVC.viewControllers[0] as! LocationsTableViewController
            locationsVC.delegate = self
        }
    }
    
    //MARK: -Actions
    
    @IBAction func saveLocation(_ sender: UIButton) {
        if !savedLocations.contains(where: { (location) -> Bool in
            location.cityName == weatherLocation.cityName
        }) {
            self.view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            self.view.bringSubviewToFront(activityIndicator)
            loading(action: {
                savedLocations.append(weatherLocation)
                Storage.store(self.savedLocations, to: .documents, as: "locations.json")
            }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.activityIndicator.removeFromSuperview()
                }
                
            }
        } else {
            let message = UIAlertController(title: "Alert", message: "This location was already saved.", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            message.addAction(ok)
            self.present(message, animated: true, completion: nil)
        }
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    @IBAction func goBack(_ sender: UIStoryboardSegue) {
        savedLocations = Storage.retrieve("locations.json", from: .documents, as: [WeatherModel].self)
    }
    
}

//MARK: -UISearchBarDelegate
extension WeatherViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let city = searchBar.text {
            self.view.addSubview(activityIndicator)
            activityIndicator.center = self.view.center
            activityIndicator.startAnimating()
            loading(action: {
                self.weatherManager.fetchWeather(cityName: city)
            }) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.activityIndicator.removeFromSuperview()
                }
            }
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

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: [WeatherModel], daily: Bool) {
        if daily {
            DispatchQueue.main.async {
                self.temperatureLabel.text = weather[0].temperatureString
                self.conditionImageView.image = UIImage(systemName: weather[0].conditionName)
                self.cityLabel.text = weather[0].cityName
                self.weatherLocation = weather[0]
            }
        } else {
            DispatchQueue.main.async { 
                self.hourWeather = weather
            }
        }
        
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: -TableViewDelegate and Datasource
extension WeatherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hourWeather?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = hourWeatherTableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherCell
        
        cell.degreesLabel.text = (hourWeather?[indexPath.row].temperatureString)! + "°"
        cell.weatherIconImageView.image = UIImage(systemName: hourWeather![indexPath.row].conditionName)
        cell.weekdayLabel.text = hourWeather?[indexPath.row].weekday
        let attributes: [NSAttributedString.Key : Any] = [
            .font : UIFont.boldSystemFont(ofSize: 25.0)]
        let attributedText = NSMutableAttributedString(string: (hourWeather?[indexPath.row].date)!)
        let hourBold = NSMutableAttributedString(string: "          " + "\((hourWeather?[indexPath.row].hour)!)", attributes: attributes)
        attributedText.append(hourBold)
        cell.dateLabel.attributedText = attributedText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = (tableView.superview?.frame.height)! / 5.0
        return height
    }
    
}

extension WeatherViewController: LocationsDelegate {
    func didSelectLocation(with cityName: String) {
        self.view.addSubview(activityIndicator)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        loading(action: {
            self.weatherManager.fetchWeather(cityName: cityName)
        }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.activityIndicator.removeFromSuperview()
            }
        }
    }
}

extension WeatherViewController {
    func loading(action: () -> Void, completion: () -> Void) {
        action()
        completion()
    }
}

extension WeatherViewController: LocationManagerDelegate {
    func didRequestLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) {
        weatherManager.fetchWeather(latitude: lat, longitude: lon)
    }
}
