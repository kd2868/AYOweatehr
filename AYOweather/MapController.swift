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

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var doubleTap = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Add the double tap recognizer
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
        
        //Handle location permission and begin getting the current location
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }

    
    /// Reset the map to the users current locaiton
    @IBAction func refresh(_ sender: Any) {
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    /// Allows both gesture recognizers to play nice with each other
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
    
    
    /// Segue to the weather page on  adouble tap
    func handleDoubleTap(sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: mapView)
        let coordinates = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        let newLocation = SelectedLocation(lat: coordinates.latitude, long: coordinates.longitude)
        self.performSegue(withIdentifier: "showWeather", sender: newLocation)
    }
    
    
    /// Load the location information to be sent to the WeatherController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWeather" {
            let guest = segue.destination as! WeatherController
            guest.curLocation = sender as! SelectedLocation
        }
    }

}

