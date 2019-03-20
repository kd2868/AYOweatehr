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
    var temp = String()
    var tempLow = String()
    var tempHigh = String()
    var humidity = Int()
    var windSpd = Int()
    
    let locationLabel = UILabel()
    let weatherLabel = UILabel()
    let tempLabel = UILabel()
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        //Get weather for the current location
        getWeather()
        
        setBackground()
        setupLocationLabel()
        setupWeatherLabel()
        setupTempLabel()
        setupTableView()
    }
    
    
    /// Makes a call to the OpenWeatherMap api to retrieve weather data for the selected locaiton
    func getWeather() {
        showActivityIndicator(on: self)
        //Set up the call
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(curLocation.lat)&lon=\(curLocation.long)&APPID=\(apiKey)")!
        //Make the call
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Error: \(error!.localizedDescription)")
                hideActivityindicator()
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
                temperature =  convertToFahrenheitFromKelvin(temperature)
                let tempInt = Int(temperature.rounded())
                self.temp = "\(tempInt)º"
            }
            
            if var tempLow = main?["temp_min"] as? Double {
                tempLow = convertToFahrenheitFromKelvin(tempLow)
                let tempLowInt = Int(tempLow.rounded())
                self.tempLow = "\(tempLowInt)º"
            }
            
            if var tempHigh = main?["temp_max"] as? Double {
                tempHigh =  convertToFahrenheitFromKelvin(tempHigh)
                let tempHighInt = Int(tempHigh.rounded())
                self.tempHigh = "\(tempHighInt)º"
            }
            
            //Humidity
            if let humid = main?["humidity"] as? Double {
                let humidInt = Int(humid.rounded())
                self.humidity = humidInt
            }
            
            //Wind speed
            let wind = json?["wind"] as? Dictionary<String, Any>
            if var speed = wind?["speed"] as? Double {
                speed = speed * 2.23694 //convert from m/s to mph
                let speedInt = Int(speed.rounded())
                self.windSpd = speedInt
            }
            
            //City
            if let cityName = json?["name"] as? String {
                self.city = cityName
            }
            
            DispatchQueue.main.async {
                hideActivityindicator()
                self.populateView()
            }
            
        } catch {
            print("Error deserializing JSON: \(error)")
            hideActivityindicator()
        }
    }

    /// Reload the Tableview with the now correct information
    func populateView() {
        locationLabel.text = city
        weatherLabel.text = weather
        tempLabel.text = temp
        tableView.reloadData()
    }
    
    //MARK: - UI Setup
    
    func setBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [turqouise.cgColor, UIColor.white.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setupLocationLabel() {
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.text = city
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        view.addSubview(locationLabel)
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        locationLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupWeatherLabel() {
        weatherLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherLabel.text = weather
        weatherLabel.textAlignment = .center
        weatherLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        view.addSubview(weatherLabel)
        weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        weatherLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 10).isActive = true
        weatherLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        weatherLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
    }
    
    func setupTempLabel() {
        tempLabel.translatesAutoresizingMaskIntoConstraints = false
        tempLabel.text = String(temp)
        tempLabel.textAlignment = .center
        tempLabel.font = UIFont.systemFont(ofSize: 64, weight: .regular)
        view.addSubview(tempLabel)
        tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tempLabel.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 5).isActive = true
        tempLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        tempLabel.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isUserInteractionEnabled = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.clear
        view.addSubview(tableView)
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: tempLabel.bottomAnchor).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

}

//MARK: - UITableView

extension WeatherController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "weatherCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Today's High: \(tempHigh)"
        case 1:
            cell.textLabel?.text = "Today's Low: \(tempLow)"
        case 2:
            cell.textLabel?.text = "Humidity: \(humidity)%"
        case 3:
            cell.textLabel?.text = "Wind speed: \(windSpd) mph"
        default:
            cell.textLabel?.text = ""
        }
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
}




