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
    
    var fetchedRequestController: NSFetchedResultsController<NSFetchRequestResult>?
    var annotations = [MKAnnotation]()
    var tapGestureRecognizer: UIGestureRecognizer!
    
    var selectMode: Bool = false
    var selectedPins: [MKAnnotationView] = []
    var queuedPin: MKAnnotationView?
    
    @IBOutlet weak var travelMap: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    @IBOutlet weak var selectionModeView: UIView!
    
    @IBOutlet weak var travelButton: UIBarButtonItem!
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Setup */
        selectionModeView.backgroundColor = ViewInterface.Constants.Colors.softRed
        selectionModeView.layer.cornerRadius = 5
        selectionModeView.layer.masksToBounds = true
        selectionModeView.layer.opacity = 0
        selectionModeView.isHidden = true
        
        // Map
        configureMap()
        
        // Gestures
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissSearchBar))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadPins()
        travelMap.deselectAnnotation(travelMap.selectedAnnotations.first, animated: false)
        
        setBottomToolbarEnabled(false)
        
        selectMode = false
        deleteButton.isEnabled = false
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // If it's in selection mode, then disable the selection mode view
        if selectMode {
            UIView.animate(withDuration: 0.5, animations: {
                self.selectionModeView.layer.opacity = 0
            }, completion: {
                (_) in
                self.selectionModeView.isHidden = true
            })
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
    
    @IBAction func showDeleteAlert() {
        
        let alertController = UIAlertController(title: "Confirm", message: "Delete the \(selectedPins.count) selected pins?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deleteSelectedPins()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
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
    
    @IBAction func toggleSelectMode() {
        
        // Toggle select mode on or off
        
        if selectMode {
            
            // Exit select mode
            
            for view in selectedPins {
                mapView(travelMap, didSelect: view) // will return opacity to normal
            }
            
            deselect(pins: selectedPins) // deselect all selected pins
            
            selectMode = false
            deleteButton.isEnabled = false
            setBottomToolbarEnabled(false)
            
            // Deselect current pin so that it can be reselected with no problem
            travelMap.deselectAnnotation(queuedPin?.annotation, animated: false)
            
            UIView.animate(withDuration: 0.5, animations: { 
                self.selectionModeView.layer.opacity = 0
            }, completion: {
                (_) in
                self.selectionModeView.isHidden = true
            })
            
        } else {
        
            // Select Mode
            deleteButton.isEnabled = true
            selectMode = true
        
            // Also, select the currently tapped on pin by calling the delegate
            // method again
            if let pin = queuedPin {
                mapView(travelMap, didSelect: pin)
            }
            
            selectionModeView.isHidden = false
            UIView.animate(withDuration: 0.5, animations: { 
                self.selectionModeView.layer.opacity = 0.8
            })
            
        }
        
    }
    
    func deleteSelectedPins() {
        deleteButton.isEnabled = false
        setBottomToolbarEnabled(false)
        
        for pin in selectedPins {
            let coordinate = pin.annotation!.coordinate
            let managedObjectPin = AppManager.main.getPin(with: coordinate.latitude, longitude: coordinate.longitude)!
            
            // Newly created pins are in background context,
            // This makes sure that they are deleted in the right context and saved if appropiate
            if managedObjectPin.managedObjectContext! === AppManager.main.coreDataStack.backgroundContext {
                AppManager.main.coreDataStack.performBackgroundBatchOperations(batch: {
                    (backgroundContext) in
                    backgroundContext.delete(managedObjectPin)
                })
            } else {
                AppManager.main.coreDataStack.context.delete(managedObjectPin)
            }
            
            travelMap.removeAnnotation(pin.annotation!)
        }
        
        selectedPins.removeAll()
        selectMode = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.selectionModeView.layer.opacity = 0
        }, completion: {
            (_) in
            self.selectionModeView.isHidden = true
        })
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
        annotations.removeAll()
        
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
                if !AppManager.main.pins.contains(pin) {
                    AppManager.main.pins.append(pin)
                }
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
    
    func deselect(pins: [MKAnnotationView]) {
        
        // Deselects all selected pins (all pin views in the array 'selectedPins')
        
        for pin in pins {
            
            for i in 0..<selectedPins.count {
                let pinCoordinate = pin.annotation!.coordinate
                let selectedPinCoordinate = selectedPins[i].annotation!.coordinate
                
                if pinCoordinate.latitude == selectedPinCoordinate.latitude && pinCoordinate.longitude == selectedPinCoordinate.longitude {
                    selectedPins.remove(at: i)
                    break
                }
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
    
    func setBottomToolbarEnabled(_ enabled: Bool) {
        travelButton.isEnabled = enabled
        selectButton.isEnabled = enabled
        
        let desiredOpacity: Float = enabled ? 1 : 0.5
        
        UIView.animate(withDuration: 0.3) { 
            self.bottomToolbar.layer.opacity = desiredOpacity
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
        
        // Make sure that it's fully visible
        // If a pin is dropped after deletion of other pins, the next one dropped will be a bit transparent
        // This fixes that. The reason is because pinViews are reused, so they will retain previous opacity
        pinView!.layer.opacity = 1
        
        // Adds the nice drop animation for the pin
        // safe to unwrap because it was created if did not exist
        pinView!.animatesDrop = true
        pinView!.detailCalloutAccessoryView = UIView()
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Manage view clicking
        
        // Acknowledge currently selected pin
        queuedPin = view
        
        // If it's in selection mode
        if selectMode {
            
            let desiredOpacity: Float = view.layer.opacity < 1 ? 1.0 : 0.3
            
            // If the desired opacity is 1, the user is trying to deselect the pin
            if desiredOpacity == 1 {
                
                if selectedPins.count == 0 {
                    deleteButton.isEnabled = false
                }
                
                deselect(pins: [view])
                
            } else {
                selectedPins.append(view)
            }
            
            UIView.animate(withDuration: 0.3) {
                view.layer.opacity = desiredOpacity
            }
            
            return
        }
        
        // Enable bottom toolbar
        setBottomToolbarEnabled(true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if !selectMode {
            setBottomToolbarEnabled(false)
        }
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
