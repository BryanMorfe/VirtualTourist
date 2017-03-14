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
    
    // MARK: Properties
    
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var mapAnnotation: MKPointAnnotation!
    var noImagesLabel: UILabel!
    var deleteButton: UIBarButtonItem!
    var selectedPaths: [IndexPath] = []
    
    @IBOutlet weak var tripMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var isLoading = false {
        didSet {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = !self.isLoading
            }
        }
    }
    
    // MARK: Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add orientation change notification
        NotificationCenter.default.addObserver(self, selector: #selector(updateViewsFrames), name: .UIDeviceOrientationDidChange, object: nil)
        
        // Start fetching asynchronously
        // If it's done synchronously, when an existing pin is tapped and is fetching all managed object photos,
        // the UI will be bloked for a brief second or two.
        DispatchQueue.main.async {
            self.startFetch()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Set the number of expected photos to zero
        // If we leave it as is, when an existing pin is tapped,
        // it will deque the same amount of cell that there were photos in previous fetch === might show + or - placeholders
        // than there actually are for a few seconds before the real expect amount is calculated.
        AppManager.main.expectedPhotoAmount = 0
        
        // Unsubscribe to orientation change
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @IBAction func getNewCollection() {
        
        // Requests a new random collection of photos from the Flickr server
        
        // Delete all photos if any
        if let photos = fetchedResultsController?.fetchedObjects as? [Photo] {
            for photo in photos {
                AppManager.main.coreDataStack.context.delete(photo)
            }
        }
        
        // Download new photos
        downloadImages()
    }
    
    func showDeleteAlert() {
        
        // Confirms to the user whether he wants to deleted the selected photos
        let alertController = UIAlertController(title: "Confirm", message: "Delete the \(selectedPaths.count) selected photos?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.deletePhotos()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true)
    }
    
    func deletePhotos() {
        deleteButton.isEnabled = false
        
        for path in selectedPaths {
            let selectedPhoto = fetchedResultsController?.object(at: path) as! Photo
            AppManager.main.coreDataStack.context.delete(selectedPhoto)
        }
        
        AppManager.main.expectedPhotoAmount -= selectedPaths.count
        
    }
    
}

// MARK: Convenience Methods

extension PhotoAlbumViewController {
    
    func downloadImages() {
        
        // Requests the start to download new photos from Flickr Server
        
        isLoading = true
        
        // Disable UI
        noImagesLabel.isHidden = true
        
        // Start request
        Flickr.shared.getImages(from: mapAnnotation.coordinate.latitude, longitude: mapAnnotation.coordinate.longitude) {
            (success, errorString) in
            
            // As soon as it finishes, it will give it the expected amount of photos
            // So we reload to show the correct number of placeholders
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
                self.isLoading = false
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
        
        /* Delete button */
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(showDeleteAlert))
        deleteButton.isEnabled = false
        navigationItem.rightBarButtonItem = deleteButton
        
    }
    
    func deselect(indexPath: IndexPath) {
        for i in 0..<selectedPaths.count {
            if selectedPaths[i].row == indexPath.row {
                selectedPaths.remove(at: i)
                break
            }
        }
    }
    
    func searchResults() {
        
        // Performs a search of Managed Objects
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
            // If there are images in this existing pin, the update the collection view
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
        // This makes sure I have the right amount of placeholders before images are loaded
        return AppManager.main.expectedPhotoAmount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! TripCollectionViewCell
        
        // Add the placeholder to the image
        cell.imageView.image = UIImage(named: "placeholder")
        
        // If I don't perform this check, Swift might try to load objects that have not been created yet,
        // therefore it would cause a horrible crash
        if let count = (fetchedResultsController?.fetchedObjects)?.count, count > indexPath.row {
            
            let photo = fetchedResultsController?.object(at: indexPath) as? Photo
            
            // If the current photo has image data, then load that image and replace the placeholder.
            if let image = photo?.image {
                cell.imageView.image = UIImage(data: image)
            }
            
            // When all images are loaded, enable the newCollectionButton
            // This also makes sure that if it tried to download and did not find any
            // the user cannot start creating multiple requests for photos that are not there right after one another
            if count == AppManager.main.expectedPhotoAmount {
                // This variable updates the newCollectionButton asynchronously
                isLoading = false
            }
            
        }
    
        return cell
    }
    
}

// MARK: Collection View Delegate

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Handles the deletions of photos
        
        // Does not allow photo deletion while images are being downloaded
        if isLoading {
            return
        }
        
        // First, find that selected photo, then remove it from the context, and decrease the number of expected photos by one
        deleteButton.isEnabled = true
        let cell = collectionView.cellForItem(at: indexPath)
        let desiredOpacity: Float = cell!.layer.opacity < 1 ? 1.0 : 0.3
        
        if desiredOpacity == 1 {
            
            deselect(indexPath: indexPath)
            
            if selectedPaths.count == 0 {
                deleteButton.isEnabled = false
            }
            
        } else {
            selectedPaths.append(indexPath)
        }
        
        UIView.animate(withDuration: 0.3) {
            cell?.layer.opacity = desiredOpacity
        }
    }
    
}

// MARK: NSFetchedResultsController Delegate

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        // Handle insertion or deletion of items
        
        switch type {
        case .delete:
            collectionView.deleteItems(at: selectedPaths)
            selectedPaths.removeAll()
        case .insert:
            collectionView.reloadItems(at: [newIndexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        case .move:
            collectionView.reloadItems(at: [indexPath!])
            collectionView.reloadItems(at: [newIndexPath!])
        }
    }
    
}
