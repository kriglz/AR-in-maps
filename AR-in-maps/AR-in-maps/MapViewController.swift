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
    private var locationManager: CLLocationManager = CLLocationManager()
    private var myLocation: CLLocationCoordinate2D?

    @IBOutlet weak var ARModeButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    private var allPins = [MKPointAnnotation]()
    private var selectedPin: String?
    private let pinAnnotationLocationCoefficients = [(-0.002, 0.001), (0.001, -0.002), (0.0005, 0.0007)]
    private let pinAnnotation = ["SHIP", "SHIP", "SHIP"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsScale = true
        mapView.showsBuildings = true
        mapView.showsUserLocation = true
        mapView.showsCompass = true

        locationManager.delegate = self
        
        setup(currentLocationButton)
        setup(ARModeButton)
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        let tapHandler = #selector(handleTapGesture(recognizer:))
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: tapHandler)
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setup(_ button: UIButton){
        button.layer.cornerRadius = 30.0
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 10.0
        button.layer.masksToBounds = false
    }
    
    @objc func handleTapGesture(recognizer: UITapGestureRecognizer){
        let tapPoint = recognizer.location(in: self.view)
        
        guard !ARModeButton.frame.contains(tapPoint), !currentLocationButton.frame.contains(tapPoint) else { return }
        
        for pin in allPins {
            let pinPoint = mapView.convert(pin.coordinate, toPointTo: self.view)
            let pinFrame = CGRect(x: pinPoint.x - 25.0, y: pinPoint.y - 50, width: 50.0, height: 50.0)
            if pinFrame.contains(tapPoint) {
                selectedPin = pin.title
            } else {
                selectedPin = nil
            }
        }
    }
    
    @IBAction func updateCurrentLocation(_ sender: Any){
        locationManager.startUpdatingLocation()
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
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            myLocation = location.coordinate
            let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
            mapView.setRegion(coordinateRegion, animated: true)
            locationManager.stopUpdatingLocation()
            
            if allPins.isEmpty {
                dropARPins()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to initialize GPS: ", error)

        let alert = UIAlertController(title: "Alert", message: "Failed to initialize GPS.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
            case .cancel:
                print("cancel")
            case .destructive:
                print("destructive")
            }}))
         self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationController = segue.destination as? ARViewController, segue.identifier == "AR" {
            if let selectedPin = selectedPin {
                destinationController.model = selectedPin
            } else {
                let alert = UIAlertController(title: "Please select the pin.", message: "", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                    case .cancel:
                        print("cancel")
                    case .destructive:
                        print("destructive")
                    }}))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func dropARPins(){
        for index in 0...2 {
            let pin = MKPointAnnotation()
            
            if let myLocation = myLocation {
                pin.coordinate.latitude = myLocation.latitude + pinAnnotationLocationCoefficients[index].0
                pin.coordinate.longitude = myLocation.longitude + pinAnnotationLocationCoefficients[index].1
                pin.title = pinAnnotation[index]
                allPins.append(pin)
                mapView.addAnnotation(pin)
            }
        }
    }
}
