//
//  ViewController.swift
//  lab7
//  GPS & Mpas
//  Created by Kiran Padinhare Kunnoth on 2023-11-10.
//  Student Id : 8940891

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate 
{

    
    //MapKitView
    @IBOutlet weak var mapUI: MKMapView!
    //buttons start and stop
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var stopButton: UIButton!
    
    //Labels with respective names
    @IBOutlet weak var currentSpeed: UILabel!
    
    
    @IBOutlet weak var maxSpeed: UILabel!
    
    
    @IBOutlet weak var avgSpeed: UILabel!
    
    
    @IBOutlet weak var distCovered: UILabel!
    
    
    @IBOutlet weak var maxAcceleration: UILabel!
    
    
    //labels for overspeed and active status
    @IBOutlet weak var overSpeedIndication: UILabel!
    
    
    @IBOutlet weak var tripActive: UILabel!
    
    
    
    
    var tripStartTime: Date?
    var isTripActive = false
    var presentSpeed: CLLocationSpeed = 0.0
    var maximumSpeed: CLLocationSpeed = 0.0
    var totalDistance: CLLocationDistance = 0.0
    var maximumAcceleration: Double = 0.0
    let areaInMeters: Double = 5000
    
    var locationManager = CLLocationManager ()
    var locations: [CLLocation] = []
    var spanPriorExceedingSpeedLimit = 0.0
    var distancePriorOverspeed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) 
    {
        //set initial location
        setToInitials()
        
        locationManager.delegate = self
        mapUI.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        mapUI.showsUserLocation = true
    }
    
    func setToInitials()
    {
        currentSpeed.text = "0 km/h"
        maxSpeed.text = "0 km/h"
        avgSpeed.text = "0 km/h"
        distCovered.text = "0 km"
        maxAcceleration.text = "0 m/s^2"
        stopButton.isEnabled = false
        tripActive.backgroundColor = UIColor.lightGray
        overSpeedIndication.backgroundColor = UIColor.clear
        locations.removeAll()
        isTripActive = false
        presentSpeed = 0.0
        maximumSpeed = 0.0
        totalDistance = 0.0
        maximumAcceleration = 0.0
        spanPriorExceedingSpeedLimit = 0.0
        distancePriorOverspeed = false
        overSpeedIndication.text = ""
    }
    
    //functions for starting the trip
    @IBAction func startButton(_ sender: Any)
    {
        tripStartTime = Date()
        setToInitials()
        locationManager.startUpdatingLocation()
        tripActive.backgroundColor = UIColor.green
        stopButton.isEnabled = true
        userLocationView()
        isTripActive = true
    }
    
    //functions for ending the trip
    @IBAction func stopTrip(_ sender: Any)
    {
        isTripActive = false
        locationManager.stopUpdatingLocation()
        // updateUI()
        tripActive.backgroundColor = UIColor.gray
        stopButton.isEnabled = false
        currentSpeed.text = "0 km/h"
        overSpeedIndication.backgroundColor = UIColor.clear
        print("Max speed == \(maximumSpeed)")
        let avg = avgSpeed.text!
        print("Average speed == \(avg)")
        let dist = distCovered.text!
        print("Distance Travelled = \(dist)")
        if !distancePriorOverspeed 
        {
            print("Distance Travelled Before Exceeding Speed Limit == \(dist)")
        
        }
    
        else
        {
            print("Distance Travelled Before Exceeding Speed Limit == \(distancePriorOverspeed)")
        }
    }
    func userLocationView() 
    {
        if let location = locationManager.location?.coordinate 
        {
            let area = MKCoordinateRegion.init(center: location, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
            mapUI.setRegion(area, animated: true)
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if(isTripActive)
        {
            guard let location = locations.last else { return }
            let centre = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion.init(center: centre, latitudinalMeters: areaInMeters, longitudinalMeters: areaInMeters)
            mapUI.setRegion(region, animated: true)
            updateTripData(newLocation: location)
            modifyMap()
            
        }
    }
    
    func modifyMap() 
    {
        
        currentSpeed.text = String(format: "%.2f km/h", presentSpeed)
        maxSpeed.text = String(format: "%.2f km/h", maximumSpeed)
        
        if locations.count > 1 
        {
            let speedsArray = locations.map { $0.speed * 3.6 } // Convert speeds to km/h
            let averageSpeed = speedsArray.reduce(0, +) / Double(speedsArray.count)
            avgSpeed.text = String(format: "%.2f km/h", averageSpeed)
        }
        else
        {
            avgSpeed.text = "0 km/h"
        }
        
        distCovered.text = String(format: "%.2f km", totalDistance / 1000)
        maxAcceleration.text = String(format: "%.2f m/s^2", maxAcceleration)
        
        if presentSpeed > 115 
        {
            if !distancePriorOverspeed
            {
                spanPriorExceedingSpeedLimit = totalDistance/1000
                distancePriorOverspeed = true
            }
            overSpeedIndication.backgroundColor = UIColor.red
        }
        else
        {
            overSpeedIndication.backgroundColor = UIColor.clear
        }
        print("Current speed == \(presentSpeed)")
    }
    
    func updateTripData(newLocation: CLLocation) 
    {
        if let startTime = tripStartTime 
        {
            let currentTime = Date()
            let timeInterval = currentTime.timeIntervalSince(startTime)
            
            let speed = newLocation.speed * 3.6 // m/s to km/h
            presentSpeed = speed
            
            if speed > maximumSpeed 
            {
                maximumSpeed = speed
            }
            
            // Append the new location to the array
            locations.append(newLocation)
            
            // Calculate distance based on the array of locations
            if locations.count > 1 
            {
                totalDistance += newLocation.distance(from: locations[locations.count - 2])
            }
            
            // Calculate acceleration (absolute value)
            let previousSpeed = locations.count > 1 ? locations[locations.count - 2].speed * 3.6 : 0.0
            let acceleration = abs((speed - previousSpeed) / timeInterval)
            if acceleration > maximumAcceleration 
            {
                maximumAcceleration = acceleration
            }
        }
        
    }
    
    
}


