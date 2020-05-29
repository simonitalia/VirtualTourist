//
//  LocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit


class LocationsMapViewController: UIViewController {
    
    //MARK:- Storyboard Outlets
    //outlets
    @IBOutlet weak var locationsMapView: MKMapView!
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureUI()

    }
    
    
    //MARK:- VC Setup
    private func configureVC() {
        locationsMapView.delegate = self
        
    }
    
    
    private func configureUI() {
        
    }
    
}


//MARK:- MKMAPView Delegate
extension LocationsMapViewController: MKMapViewDelegate  {

    
}
