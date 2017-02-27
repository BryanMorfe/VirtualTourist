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
    
    var shouldDownloadImages: Bool = true
    
    var noImagesLabel: UILabel!
    
    @IBOutlet weak var tripMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewsFrames), name: .UIDeviceOrientationDidChange, object: nil)
        
        DispatchQueue.main.async {
            self.startFetch()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppManager.main.expectedPhotoAmount = 0
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func getNewCollection() {
        
        // Delete all photos if any
        if let photos = fetchedResultsController?.fetchedObjects as? [Photo] {
            for photo in photos {
                AppManager.main.coreDataStack.context.delete(photo)
            }
        }
        
        // Download new photos
        
        // Need to fix it because these photos are created in background context and the pins are in main context
        downloadImages()
    }
    
}

// MARK: Convenience Methods

extension PhotoAlbumViewController {
    
    func downloadImages() {
        
        // Disable UI and set loading state
        newCollectionButton.isEnabled = false
        noImagesLabel.isHidden = true
        
        Flickr.shared.getImages(from: mapAnnotation.coordinate.latitude, longitude: mapAnnotation.coordinate.longitude) {
            (success, errorString) in
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            if success {
                
                // If there are no images fetched, then show the no images label
                if AppManager.main.expectedPhotoAmount == 0 {
                    DispatchQueue.main.async {
                        self.noImagesLabel.isHidden = false
                    }
                }
                
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
        collectionView.delegate = self
        
        /* No images label */
        
        noImagesLabel = UILabel()
        noImagesLabel.text = "No Images Found"
        noImagesLabel.font = UIFont(name: ".SFUIText-Bold", size: 18)
        noImagesLabel.textColor = .lightGray
        noImagesLabel.textAlignment = .center
        noImagesLabel.isHidden = true
        
        /* Update the frames of the collection view and noImagesLabel */
        updateViewsFrames()
        
        collectionView.addSubview(noImagesLabel)
        
    }
    
    func searchResults() {
        
        do {
            try self.fetchedResultsController!.performFetch()
        } catch let error {
            print("Error while performing search: \(error.localizedDescription)")
        }
        
    }
    
    func startFetch() {
            
        // Create and configure request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: AppManager.Constants.EntityNames.photo)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
        let predicate = NSPredicate(format: "pin = %@", argumentArray: [AppManager.main.currentPin!])
        fetchRequest.predicate = predicate
            
            
        // Create fetched results controller
        fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: AppManager.main.coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
            
        // Set the delegate
        fetchedResultsController!.delegate = self
            
        /* Perform search */
        searchResults()
            
        if let count = fetchedResultsController!.fetchedObjects?.count, count > 0 {
            // Reload collection view data
            AppManager.main.expectedPhotoAmount = count
            collectionView.reloadData()
        } else {
            // If there are no images, then start downloading.
            downloadImages()
        }
        
    }
    
    func updateViewsFrames() {
        
        /* Collection View */

        let desiredAmountOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = 3 / 2
        let totalAvailableWidth = view.frame.width - 6
        let dimensions = (totalAvailableWidth / desiredAmountOfItemsPerRow) - ((desiredAmountOfItemsPerRow - 1) * spacing)
        collectionViewFlowLayout.itemSize = CGSize(width: dimensions, height: dimensions)
        collectionViewFlowLayout.minimumInteritemSpacing = spacing
        collectionViewFlowLayout.minimumLineSpacing = spacing * 2
        
        /* No Images Label */
        noImagesLabel.frame = CGRect(x: collectionView.frame.size.width * 0.10, y: (collectionView.frame.size.height / 2) - 22, width: collectionView.frame.size.width * 0.80, height: 44)
    }
    
}

// MARK: Collection View Data Source

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return AppManager.main.expectedPhotoAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! TripCollectionViewCell
        
        cell.imageView.image = UIImage(named: "placeholder")
        
        if let count = (fetchedResultsController?.fetchedObjects)?.count, count > indexPath.row {
            
            let photo = fetchedResultsController?.object(at: indexPath) as? Photo
            
            if let image = photo?.image {
                cell.imageView.image = UIImage(data: image)
            }
            
            if count == AppManager.main.expectedPhotoAmount {
                // Enable UI
                DispatchQueue.main.async {
                    self.newCollectionButton.isEnabled = true
                }
            }
            
        }
    
        return cell
    }
    
}

// MARK: Collection View Delegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhoto = fetchedResultsController?.object(at: indexPath) as! Photo
        AppManager.main.coreDataStack.context.delete(selectedPhoto)
        AppManager.main.expectedPhotoAmount -= 1
    }
    
}

// MARK: NSFetchedResultsController Delegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
}
