//
//  MapViewController.swift
//  AR-in-maps
//
//  Created by Kristina Gelzinyte on 1/8/18.
//  Copyright © 2018 Kristina Gelzinyte. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?

    @IBOutlet weak var currentLocationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsScale = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        updateButtonShadow()
        
        if let locationManager = locationManager {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                currentLocationButton.isHidden = false
            } else {
                let alert = UIAlertController(title: "Alert", message: "Failed to initialize GPS.\nPlease enable location access in Settings -> AR-in-maps -> Location", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    switch action.style {
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }}))
                self.present(alert, animated: true, completion: nil)
                currentLocationButton.isHidden = true
            }
        }
    }
    
    private func updateButtonShadow(){
        currentLocationButton.layer.cornerRadius = 30.0
        currentLocationButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        currentLocationButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        currentLocationButton.layer.shadowOpacity = 1.0
        currentLocationButton.layer.shadowRadius = 10.0
        currentLocationButton.layer.masksToBounds = false
    }
    
    @IBAction func updateCurrentLocation(_ sender: Any) {
        
        if let myLocation = myLocation {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(myLocation, 500, 500)
            mapView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("NotDetermined")
        case .restricted:
            print("Restricted")
        case .denied:
            print("Denied")
        case .authorizedAlways:
            print("AuthorizedAlways")
        case .authorizedWhenInUse:
            print("AuthorizedWhenInUse")
            if let locationManager = locationManager {
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    private var myLocation: CLLocationCoordinate2D?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = location.coordinate
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager?.stopUpdatingLocation()
            locationManager = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = UIAlertController(title: "Alert", message: "Failed to initialize GPS.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }})
        )
        print("Failed to initialize GPS: ", error.localizedDescription)
    }
}
