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
    
    // MARK: Properties
    static var showedInstructionsController: Bool = false
    static var showedInstructionsAnnotation: Bool = !AppManager.main.isFirstLaunch
    
    var fetchedRequestController: NSFetchedResultsController<NSFetchRequestResult>?
    var annotations = [MKAnnotation]()
    var tapGestureRecognizer: UIGestureRecognizer!
    
    var selectMode: Bool = false
    var selectedPins: [MKAnnotation] = []
    var queuedPin: MKAnnotationView?
    
    @IBOutlet weak var travelMap: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    @IBOutlet weak var travelButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup */
        
        // Map
        configureMap()
        
        // Gestures
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearchBar))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPins()
        travelMap.deselectAnnotation(travelMap.selectedAnnotations.first, animated: false)
        
        // Bar Buttons
        deleteButton.isEnabled = false
        travelButton.isEnabled = false
        selectButton.isEnabled = false
        
        selectMode = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // For first launches
        if AppManager.main.isFirstLaunch == true && !TravelMapViewController.showedInstructionsController {
            // Because the instructions/welcome screen are in portrait, make it portrait before presenting it.
            TravelMapViewController.showedInstructionsController = true // Tell it to not show it more even if it's first launch
            showInstructions() // The intructions view controller presents the welcome screen for first timers.
        }
    }
    
    // MARK: Actions
    
    @IBAction func showInstructions() {
        
        // Because the instructions are in portrait, make it portrait before presenting it.
        if UIDevice.current.orientation != .portrait {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
        }
        
        let controller = FlightInstructionsViewController()
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func deleteSelectedPins() {
        deleteButton.isEnabled = false
        travelButton.isEnabled = false
        selectButton.isEnabled = false
        
        for pin in selectedPins {
            travelMap.removeAnnotations(selectedPins)
            let coordinate = pin.coordinate
            let managedObjectPin = AppManager.main.getPin(with: coordinate.latitude, longitude: coordinate.longitude)!
            AppManager.main.coreDataStack.context.delete(managedObjectPin)
        }
        
        selectedPins.removeAll()
        selectMode = false
    }
    
    @IBAction func travel() {
        
        deleteButton.isEnabled = false
        selectButton.isEnabled = false
        
        if let pin = queuedPin {
            
            // Create a instance of the PhotoAlbumView with storyboard instatiation
            let photoAlbumController = storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            photoAlbumController.mapAnnotation = pin.annotation as! MKPointAnnotation
            
            pin.setSelected(false, animated: false) // Deselect pin
            AppManager.main.currentPin = AppManager.main.getPin(with: pin.annotation!.coordinate.latitude, longitude: pin.annotation!.coordinate.longitude)
            
            navigationController!.pushViewController(photoAlbumController, animated: true)
            
        }
        
    }
    
    @IBAction func enableSelectMode() {
        
        // Select Mode
        deleteButton.isEnabled = true
        selectMode = true
        
        // Also, select the currently tapped on pin by calling the delegate
        // method again
        if let pin = queuedPin {
            mapView(travelMap, didSelect: pin)
        }
        
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
        
        // Manages the tap and hold gesture.
        
        // If it's in select mode, do not allow to drop new pins
        
        if selectMode {
            return
        }
        
        if gestureRecognizer.state == .began {
            
            // Converts the touch point into coordinates and creates an annotation for the map
            let touchLocation = gestureRecognizer.location(in: travelMap)
            let touchCoordinate = travelMap.convert(touchLocation, toCoordinateFrom: travelMap)
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchCoordinate
            travelMap.addAnnotation(annotation)
            annotations.append(annotation)
            
            // Check if it's an existing pin else create a new pin object and assign to current working pin in app manager.
            if let pin = AppManager.main.getPin(with: touchCoordinate.latitude, longitude: touchCoordinate.longitude) {
                AppManager.main.currentPin = pin
            } else {
                // Because the Photo Managed Object in created in the background context, we need to make sure that this Pin is also in the
                // background context. Also, that assures the UI does not get blocked from loading things.
                AppManager.main.coreDataStack.performBackgroundBatchOperations {
                    backgroundContext in
                    AppManager.main.currentPin = Pin(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, context: backgroundContext)
                    AppManager.main.pins.append(AppManager.main.currentPin!)
                }
            }
        }
        
    }

}

// MARK: Convenience Methods

extension TravelMapViewController {
    
    func loadPins() {
        
        /* This method loads all the pins from core data */
        
        // First remove the ones in annotations so there are no duplicates
        travelMap.removeAnnotations(annotations)
        annotations = []
        
        // Fetch all Pins
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppManager.Constants.EntityNames.pin)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        fetchedRequestController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppManager.main.coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedRequestController!.performFetch()
        } catch {
            print("Cannot perform search.")
        }
        
        // Create an annotation for all pins
        if let pins = fetchedRequestController?.fetchedObjects as? [Pin], pins.count > 0 {
            
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
                annotations.append(annotation)
                AppManager.main.pins.append(pin)
            }
            
            DispatchQueue.main.async {
                self.travelMap.addAnnotations(self.annotations)
            }
        }
    }
    
    func updateMapState() {
        
        // Tells the app manager of the new Map state
        
        let mapStateDictionary = [
            AppManager.Constants.MapState.latitudeDelta : travelMap.region.span.latitudeDelta,
            AppManager.Constants.MapState.longitudeDelta : travelMap.region.span.longitudeDelta,
            AppManager.Constants.MapState.latitude : travelMap.region.center.latitude,
            AppManager.Constants.MapState.longitude : travelMap.region.center.longitude
        ]
        
        AppManager.main.mapState = mapStateDictionary as [String : AnyObject]
    }
    
    func deselect(pin: MKPointAnnotation) {
        
        for i in 0..<selectedPins.count {
            let coordinate = selectedPins[i].coordinate
            if coordinate.latitude == pin.coordinate.latitude && coordinate.longitude == pin.coordinate.longitude {
                selectedPins.remove(at: i)
                break
            }
        }
        
    }
    
    func dismissSearchBar(_ tapGesture: UITapGestureRecognizer) {
        
        // Stops search bar editing when map is tapped and is searching
        if tapGesture.state == .recognized {
            
            if searchBar.isFirstResponder {
                searchBar.resignFirstResponder()
            }
            
            travelMap.removeGestureRecognizer(tapGestureRecognizer)
        }
        
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
        
        // Adds the nice drop animation for the pin
        // safe to unwrap because it was created if did not exist
        pinView!.animatesDrop = true
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Manage view clicking
        
        if selectMode {
            
            let desiredOpacity: Float = view.layer.opacity < 1 ? 1.0 : 0.3
            
            // If the desired opacity is 1, the user is trying to deselect the pin
            if desiredOpacity == 1 {
                
                if selectedPins.count == 0 {
                    deleteButton.isEnabled = false
                }
                
                deselect(pin: view.annotation as! MKPointAnnotation)
                
            } else {
                selectedPins.append(view.annotation as! MKPointAnnotation)
            }
            
            UIView.animate(withDuration: 0.3) {
                view.layer.opacity = desiredOpacity
            }
            
            return
        }
        
        // Enable options
        travelButton.isEnabled = true
        selectButton.isEnabled = true
        
        // Acknowledge currently selected pin
        queuedPin = view
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Update the app manager with latest map state
        updateMapState()
    }

}

// MARK: Search Bar Delegate

extension TravelMapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // Make sure there is text to search
        guard let text = searchBar.text, !text.isEmpty else {
            print("No text could be retrieved")
            return
        }
        
        // Geocode string
        CLGeocoder().geocodeAddressString(text) { (placemarks, error) in
            
            guard error == nil else {
                print("Unable to geocode \(text).")
                return
            }
            
            guard let placemarks = placemarks else {
                print("Unable to retrieve placemarks.")
                return
            }
            
            // Do some magic by going to the region
            let placemark = placemarks[0]
            let coordinate = placemark.location!.coordinate
            let span = MKCoordinateSpanMake(0.3, 0.3)
            let region = MKCoordinateRegionMake(coordinate, span)
            
            DispatchQueue.main.async {
                // Dismiss search bar and set the map region
                searchBar.resignFirstResponder()
                self.travelMap.setRegion(region, animated: true)
            }
            
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        // When the search bar is being edited, add the tap gesture to the map,
        // This gesture is removed when performed, that way is only there when editing search bar
        travelMap.addGestureRecognizer(tapGestureRecognizer)
    }
    
}
