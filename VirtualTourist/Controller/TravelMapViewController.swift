//
//  TravelMapViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: UIViewController {
    
    var fetchedRequestController: NSFetchedResultsController<NSFetchRequestResult>?
    
    @IBOutlet weak var travelMap: MKMapView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPins()
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
        if let mapState = AppManager.main.mapState {
            
            let latitudeDelta = mapState[AppManager.Constants.MapState.latitudeDelta] as! Double
            let longitudeDelta = mapState[AppManager.Constants.MapState.longitudeDelta] as! Double
            let latitude = mapState[AppManager.Constants.MapState.latitude] as! Double
            let longitude = mapState[AppManager.Constants.MapState.longitude] as! Double
            
            let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            let regionSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
            let region = MKCoordinateRegionMake(coordinate, regionSpan)
            
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
    
    func loadPins() {
        
        var annotations = [MKAnnotation]()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppManager.Constants.EntityNames.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        fetchedRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppManager.main.coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedRequestController!.performFetch()
        } catch {
            print("Cannot perform search.")
        }
        
        if let pins = fetchedRequestController?.fetchedObjects as? [Pin], pins.count > 0 {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                annotations.append(annotation)
            }
            
            DispatchQueue.main.async {
                self.travelMap.addAnnotations(annotations)
            }
        }
    }
    
    func updateMapState() {
        let mapStateDictionary = [
            AppManager.Constants.MapState.latitudeDelta : travelMap.region.span.latitudeDelta,
            AppManager.Constants.MapState.longitudeDelta : travelMap.region.span.longitudeDelta,
            AppManager.Constants.MapState.latitude : travelMap.region.center.latitude,
            AppManager.Constants.MapState.longitude : travelMap.region.center.longitude
        ]
        
        AppManager.main.mapState = mapStateDictionary as [String : AnyObject]
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
        
        // Manage view clicking
        let photoAlbumController = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumController.mapAnnotation = view.annotation as! MKPointAnnotation
        
        view.setSelected(false, animated: false) // Deselect pin
        
        navigationController!.pushViewController(photoAlbumController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.navigationController!.navigationBar.alpha = 1
        }
        updateMapState()
    }

}
