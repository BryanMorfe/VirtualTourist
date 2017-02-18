//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Bryan Morfe on 2/14/17.
//  Copyright © 2017 Morfe. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    var mapAnnotation: MKPointAnnotation!
    
    @IBOutlet weak var tripMap: MKMapView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    @IBAction func getNewCollection() {
        
    }
}

// MARK: Convenience Methods

extension PhotoAlbumViewController {
    
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
        let spacing: CGFloat = 3
        let totalAvailableWidth = view.frame.width - 6
        let dimensions = (totalAvailableWidth / desiredAmountOfItemsPerRow) - ((desiredAmountOfItemsPerRow - 1) * spacing)
        collectionViewFlowLayout.itemSize = CGSize(width: dimensions, height: dimensions)
        collectionViewFlowLayout.minimumInteritemSpacing = spacing
    }
    
}

// MARK: Collection View Data Source

extension PhotoAlbumViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlickrImageCell", for: indexPath) as! TripCollectionViewCell
        return cell
    }
    
}
