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
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var locationsMapView: MKMapView!
    
    
    //actions
    @IBAction func locationsMapLongPressed(_ sender: Any) {
        let coordinates = getMapCoordinatesFrom(gestureRecognizer: sender as! UILongPressGestureRecognizer)
        
    }
    
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


//MARK: - Helpers
extension LocationsMapViewController {
    
    func getMapCoordinatesFrom(gestureRecognizer: UILongPressGestureRecognizer) -> CLLocationCoordinate2D {
        let touch: CGPoint = gestureRecognizer.location(in: locationsMapView)
        let mapCoordinates: CLLocationCoordinate2D = locationsMapView.convert(touch, toCoordinateFrom: locationsMapView)
        return mapCoordinates
    }
}


//MARK:- MKMAPView Delegate
extension LocationsMapViewController: MKMapViewDelegate  {

    
}
