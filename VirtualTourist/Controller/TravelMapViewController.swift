//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import MapKit

class TravelMapViewController: UIViewController {
    
    @IBOutlet weak var travelMap: MKMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if AppManager.main.isFirstLaunch == true {
            AppManager.main.isFirstLaunch = false
            if UIDevice.current.orientation != .portrait {
                UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            }
            let controller = FlightInstructionsViewController()
            present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func showInstructions() {
        
        if UIDevice.current.orientation != .portrait {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
        let controller = FlightInstructionsViewController()
        present(controller, animated: true, completion: nil)
        
    }
    
    func configureMap() {
        
        /* Map */
        travelMap.delegate = self
        
        // Long Press Gesture
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(dropPin))
        travelMap.addGestureRecognizer(longPressGestureRecognizer)
        
        // Recover last state (if any)
        let appManager = AppManager.main
        
        if let latitudeDelta = appManager.latitudeDelta, let longitudeDelta = appManager.longitudeDelta,
            let latitude = appManager.latitude, let longitude = appManager.latitude {
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let regionSpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(latitudeDelta), longitudeDelta: CLLocationDegrees(longitudeDelta))
            let region = MKCoordinateRegionMake(coordinate, regionSpan)
            print("LatDelta: \(latitudeDelta), LonDelta: \(longitudeDelta), Lat: \(latitude), Lon: \(longitude),")
            travelMap.setRegion(region, animated: false)
        }
    }
    
    func dropPin(gestureRecognizer: UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let touchLocation = gestureRecognizer.location(in: travelMap)
            let touchCoordinate = travelMap.convert(touchLocation, toCoordinateFrom: travelMap)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            travelMap.addAnnotation(annotation)
        }
        
    }

}

// MARK: Convenience Methods

extension TravelMapViewController {
    
    func saveMapState() {
        UserDefaults.standard.set(travelMap.region.span.latitudeDelta, forKey: AppManager.Constants.mapLatitudeDelta)
        UserDefaults.standard.set(travelMap.region.span.longitudeDelta, forKey: AppManager.Constants.mapLongitudeDelta)
        UserDefaults.standard.set(travelMap.region.center.latitude, forKey: AppManager.Constants.mapLatitud)
        UserDefaults.standard.set(travelMap.region.center.longitude, forKey: AppManager.Constants.mapLongitud)
    }
    
}


// MARK: Map View Delegate

extension TravelMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "travelPin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
        
        pinView!.animatesDrop = true
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        saveMapState()
        
        // Manage view clicking
        let photoAlbumController = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumController.mapAnnotation = view.annotation as! MKPointAnnotation
        
        navigationController!.pushViewController(photoAlbumController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.3) { 
            self.navigationController!.navigationBar.alpha = 0.3
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.navigationController!.navigationBar.alpha = 1
        }
        saveMapState()
    }

}