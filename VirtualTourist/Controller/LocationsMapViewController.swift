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
        let mapCoordinates = getMapCoordinatesFrom(longPressGestureRecognizer: sender as! UILongPressGestureRecognizer)
        setLocationMapPointAnnotation(at: mapCoordinates)
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
    
    func getMapCoordinatesFrom(longPressGestureRecognizer touchPoint: UILongPressGestureRecognizer) -> CLLocationCoordinate2D {
        let touchPoint: CGPoint = touchPoint.location(in: locationsMapView)
        let mapCoordinates: CLLocationCoordinate2D = locationsMapView.convert(touchPoint, toCoordinateFrom: locationsMapView)
        return mapCoordinates
    }
    
    
    //once annotatioon is added to map view, delegate will add to map
    func setLocationMapPointAnnotation(at coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        //add annotation to map view
        DispatchQueue.main.async {
            self.locationsMapView.addAnnotation(annotation) //done on main thread so pins appear on view/map load
        }
    }
}


//MARK:- MKMAPView Delegate
extension LocationsMapViewController: MKMapViewDelegate  {

    //cretaes and sets pin views on map when annotations added to map view
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
}
