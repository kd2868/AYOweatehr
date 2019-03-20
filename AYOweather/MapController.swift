//
//  ViewController.swift
//  AYOweather
//
//  Created by Kevin Danaher on 9/13/17.
//  Copyright © 2017 TeachMe, Inc. All rights reserved.
//

import UIKit
import MapKit

class MapController: UIViewController, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    
    var locationManager: CLLocationManager!
    var doubleTap = UITapGestureRecognizer()
    
    let mapView = MKMapView()
    let locateButton = UIButton(type: .system)
    let infoButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the double tap recognizer
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        
        setupMapView()
        setupLocateButton()
        setupInfoButton()
        refresh()
    }

    /// Reset the map to the users current locaiton
    @objc func refresh() {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Give instructions on how to show weather
    @objc func infoPressed() {
        let alertCtrl = UIAlertController(title: "AnyWeather", message: "Double tap on any location to see the weather there!", preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "That's Awesome!", style: .default, handler: nil)
        alertCtrl.addAction(doneAction)
        self.present(alertCtrl, animated: true, completion: nil)
    }
    
    /// Allows both gesture recognizers to play nice with each other
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /// Segue to the weather page on a double tap
    @objc func handleDoubleTap(sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let coordinates = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        let newLocation = SelectedLocation(lat: coordinates.latitude, long: coordinates.longitude)
        
        let weatherVC = WeatherController()
        weatherVC.curLocation = newLocation
        self.navigationController?.pushViewController(weatherVC, animated: true)
    }

    /// Grab's the last locaiton in the array as the user's current location and zooms the map in on that location.
    ///
    /// - Parameters:
    ///   - manager: generic location manager
    ///   - locations: coordinates of current locations
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: (location.coordinate.longitude))
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
        
        locationManager.stopUpdatingLocation()
    }

    //MARK: - UI Setup
    
    func setupMapView() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mapView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        mapView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }
    
    func setupLocateButton() {
        locateButton.translatesAutoresizingMaskIntoConstraints = false
        locateButton.frame = CGRect(x: 200, y: 200, width: 80, height: 80)
        locateButton.layer.cornerRadius = locateButton.bounds.width / 2
        locateButton.layer.masksToBounds = true
        locateButton.backgroundColor = UIColor(white: 1, alpha: 0.75)
        locateButton.layer.shadowColor = UIColor.lightGray.cgColor
        locateButton.layer.shadowRadius = 3
        locateButton.addTarget(self, action: #selector(refresh), for: .touchUpInside)
        locateButton.setImage(#imageLiteral(resourceName: "Locate"), for: .normal)
        view.addSubview(locateButton)
        locateButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        locateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        locateButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        locateButton.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func setupInfoButton() {
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.frame = CGRect(x: 200, y: 200, width: 40, height: 40)
        infoButton.layer.cornerRadius = infoButton.bounds.width / 2
        infoButton.layer.masksToBounds = true
        infoButton.backgroundColor = UIColor(white: 1, alpha: 0.75)
        infoButton.addTarget(self, action: #selector(infoPressed), for: .touchUpInside)
        infoButton.setImage(#imageLiteral(resourceName: "Info"), for: .normal)
        view.addSubview(infoButton)
        infoButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12).isActive = true
        infoButton.bottomAnchor.constraint(equalTo: locateButton.topAnchor, constant: -10).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
}

