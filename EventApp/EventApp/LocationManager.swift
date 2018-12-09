//
//  LocationManager.swift
//  EventApp
//
//  Created by Tim Bolzern on 09.12.18.
//  Copyright © 2018 2noobs. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject,CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    
    func startTracking(){
        print("started Tracking")
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        print(self.currentLocation)
    }
    
    func stopTracking(){
        print("stopped Tracking")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.currentLocation = location
        }
    }
    
    func getDistanceInMeters(coordinate1: CLLocation, coordinate2: CLLocation) -> Double{
        return coordinate1.distance(from: coordinate2)
    }
}
