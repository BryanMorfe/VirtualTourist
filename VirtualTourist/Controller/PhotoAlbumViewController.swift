//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    
    var mapAnnotation: MKPointAnnotation!
    
    var loadingIndicator: DotLoadingIndicator!
    
    @IBOutlet weak var tripMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadImages()
    }

    @IBAction func getNewCollection() {
        
    }
}

// MARK: Convenience Methods

extension PhotoAlbumViewController {
    
    func loadImages() {
        // Disable UI and set loading state
        newCollectionButton.isEnabled = false
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimation()
        Flickr.shared.getImages(from: mapAnnotation.coordinate.latitude, longitude: mapAnnotation.coordinate.longitude) { (success, errorString) in
            // Enable UI
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
                self.loadingIndicator.stopAnimation()
                self.loadingIndicator.isHidden = true
            }
            
            if success {
                self.setupFetchedResultsController()
            } else {
                print(errorString!)
            }
            
        }
        
    }
    
    func setupViews() {
        
        /* Map */
        
        // Disable Movement
        tripMap.isZoomEnabled = false
        tripMap.isScrollEnabled = false
        tripMap.isRotateEnabled = false
        tripMap.isPitchEnabled = false
        
        // Center and add annotation
        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        let mapRegion = MKCoordinateRegionMake(mapAnnotation.coordinate, span)
        tripMap.setRegion(mapRegion, animated: false)
        tripMap.addAnnotation(mapAnnotation)
        
        /* Collection View */
        
        collectionView.dataSource = self
        
        // Cell Layout
        let desiredAmountOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 3 / 2
        let totalAvailableWidth = view.frame.width - 6
        let dimensions = (totalAvailableWidth / desiredAmountOfItemsPerRow) - ((desiredAmountOfItemsPerRow - 1) * spacing)
        collectionViewFlowLayout.itemSize = CGSize(width: dimensions, height: dimensions)
        collectionViewFlowLayout.minimumInteritemSpacing = spacing
        collectionViewFlowLayout.minimumLineSpacing = spacing * 2
        
        /* Loading Indicator */
        
        loadingIndicator = DotLoadingIndicator()
        loadingIndicator.dotStyle = .largeGray
        loadingIndicator.frame.origin = CGPoint(x: (collectionView.frame.size.width / 2) - (loadingIndicator.frame.size.width / 2), y: (collectionView.frame.size.height / 2) - (loadingIndicator.frame.size.height / 2))
        loadingIndicator.isHidden = false
        collectionView.addSubview(loadingIndicator)
        
    }
    
    func setupFetchedResultsController() {
        
        // Create request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppManager.Constants.EntityNames.photo)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        // Create fetched results controller
        fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: AppManager.main.coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Set the delegate
        fetchedResultsController!.delegate = self
        
        /* Perform search */
        do {
            try fetchedResultsController!.performFetch()
        } catch let error {
            print("Error while performing search: \(error.localizedDescription)")
        }
        
        // Reload new data
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
}

// MARK: Collection View Data Source

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].objects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! TripCollectionViewCell
        
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        
        let image = UIImage(data: photo.image!)
        
        cell.imageView.image = image
        
        return cell
    }
    
}

// MARK: NSFetchedResultsController Delegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
}
