//
//  Constants.swift
//  AYOweather
//
//  Created by Kevin Danaher on 9/13/17.
//  Copyright © 2017 TeachMe, Inc. All rights reserved.
//

import Foundation
import UIKit

//MARK: - Variables

let apiKey = "24ce6994f7ce6a61749328f894d78a3a" //Key for the OpenWeatherMap api
let activityIndicator = UIActivityIndicatorView()
let turqouise = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)

//MARK: - Structs

//Stores coordinates for the location selected on the map
struct SelectedLocation {
    var lat = Double()
    var long = Double()
    
}

//MARK: - Functions

func convertToFahrenheitFromKelvin(_ kelvin: Double) -> Double {
    return (kelvin * (9/5)) - 459.67
}

func showActivityIndicator(on view: UIViewController) {
    activityIndicator.center = view.view.center
    activityIndicator.hidesWhenStopped = true
    activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
    activityIndicator.color = UIColor.gray
    view.view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    UIApplication.shared.beginIgnoringInteractionEvents()
}

func hideActivityindicator() {
    UIApplication.shared.endIgnoringInteractionEvents()
    activityIndicator.stopAnimating()
}
