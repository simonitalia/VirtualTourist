//
//  PhotoAlbumMapViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumMapViewController: UIViewController {
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
     //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.annotations.forEach{mapView.removeAnnotation($0)}
        mapView.delegate = nil
        print("PhotoAlbumMapViewController viewWillDisappear called")
    }
    
}
