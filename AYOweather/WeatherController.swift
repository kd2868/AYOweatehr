//
//  WeatherController.swift
//  AYOweather
//
//  Created by Kevin Danaher on 9/13/17.
//  Copyright © 2017 TeachMe, Inc. All rights reserved.
//

import UIKit

class WeatherController: UIViewController {
    
    var curLocation = SelectedLocation()
    var city = String()
    var weather = String()
    var weatherDescription = String()
    var windSpd = Double()
    var temp = Double()
    var humidity = Double()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set uo the tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = false
        tableView.tableFooterView = UIView()
        
        //Get weather for the current location
        getWeather()
    }
    
    
    /// Makes a call to the OpenWeatherMap api to retrieve weather data for the selected locaiton
    func getWeather() {
        //Set up the call
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(curLocation.lat)&lon=\(curLocation.long)&APPID=\(apiKey)")!
        //Make the call
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
            } else {
                print(data!) // JSON Serialization
                self.parseJSON(data: data!)
            }
        }
        task.resume()
    }
    
    
    /// Parse through the JSON response
    ///
    /// - Parameter data: the JSON response
    func parseJSON(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            //Generic weather
            let allWeather = json?["weather"] as? [[String: Any]]
            for item in allWeather! {
                if let main = item["main"] as? String {
                    self.weather = main
                }
                if let desc = item["description"] as? String {
                    self.weatherDescription = desc
                }
            }
            
            let main = json?["main"] as? Dictionary<String, Any>
            
            //Temperature
            if var temperature = main?["temp"] as? Double {
                temperature =  (temperature * (9/5)) - 459.67 //Convert from Kelvin to Fahrenheit
                self.temp = temperature
            }
            
            //Humidity
            if let humid = main?["humidity"] as? Double {
                self.humidity = humid
            }
            
            //Wind speed
            let wind = json?["wind"] as? Dictionary<String, Any>
            if let speed = wind?["speed"] as? Double {
                self.windSpd = speed
            }
            
            //City
            if let cityName = json?["name"] as? String {
                self.city = cityName
            }
            
            OperationQueue.main.addOperation {
                self.populateView()
            }
            
        } catch {
            print("Error deserializing JSON: \(error)")
        }
    }

    /// Reload the Tableview with the now correct information
    func populateView() {
        self.navigationItem.title = city
        tableView.reloadData()
    }

}

extension WeatherController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "weatherCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let row = indexPath.row
        if row == 0 {
            cell.textLabel?.text = weather
            cell.textLabel?.textAlignment = .center
        }
        else if row == 1 {
            cell.textLabel?.text = weatherDescription
            cell.textLabel?.textAlignment = .center
        }
        else if row == 2 {
            cell.textLabel?.text = "Current temperature: \(temp)°"
        }
        else if row == 3 {
            cell.textLabel?.text = "Humidity: \(humidity)%"
        }
        else if row == 4 {
            cell.textLabel?.text = "Wind speed: \(windSpd)"
        }
        
        return cell
    }
    
}




