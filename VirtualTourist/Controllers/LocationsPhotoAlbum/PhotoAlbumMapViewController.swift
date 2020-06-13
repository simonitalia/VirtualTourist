//
//  PhotoAlbumMapViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumMapViewController: PhotoAlbumMasterViewController {
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //MARK: Class Properties
    private var pin: Pin? {
        return PhotoAlbumMasterViewController.pin
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureUI()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView.annotations.forEach{ mapView.removeAnnotation($0) }
        mapView.delegate = nil
        print("PhotoAlbumMapViewController viewWillDisappear called")
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {}
    
    
    private func configureVC() {
        mapView.delegate = self
    }
    
    
    private func configureUI() {
        guard let pin = pin else { return }
        
        let annotation = mapView.createMapPointAnnotation(from: pin)
        mapView.updateMapView(with: [annotation])
        mapView.centerCoordinate = annotation.coordinate //move map to coordinates
    }
}

