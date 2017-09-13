//
//  Constants.swift
//  AYOweather
//
//  Created by Kevin Danaher on 9/13/17.
//  Copyright © 2017 TeachMe, Inc. All rights reserved.
//

import Foundation

//Key for the OpenWeatherMap api
let apiKey = "24ce6994f7ce6a61749328f894d78a3a"

//Stores coordinates for the location selected on the map
struct SelectedLocation {
    var lat = Double()
    var long = Double()
}
