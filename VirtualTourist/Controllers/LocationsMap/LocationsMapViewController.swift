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
    
    //MARK:- Class Properties
    enum SegueIdentifier {
        static let segueToPhotoAlbumViewController = "LocationsMapVCToPhotoAlbumVC"
    }
    
    private var annotationTapped: MKAnnotation!
    private var region: MKCoordinateRegion? {
        return AppDelegate.region
    }
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    //actions
    @IBAction func locationsMapLongPressed(_ sender: Any) {
        let mapCoordinates = getMapCoordinatesFrom(longPressGestureRecognizer: sender as! UILongPressGestureRecognizer)
        mapView.setMapPointAnnotation(at: mapCoordinates)
    }
    
    
    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    
    //MARK:- VC Setup
    private func configureVC() {
        mapView.delegate = self
    }
    
    
    func configureUI() {
        //set region (if saved)
        if let region = region {
            mapView.region = region
        }
    }
    
    
    //MARK: Navigation Setup
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let annotation = self.annotationTapped else { return }
        
        if segue.identifier == SegueIdentifier.segueToPhotoAlbumViewController {
            PhotoAlbumViewController.annotation = annotation
        }
    }
}


//MARK: - Helpers
extension LocationsMapViewController {
    
    private func getMapCoordinatesFrom(longPressGestureRecognizer touchPoint: UILongPressGestureRecognizer) -> CLLocationCoordinate2D {
        let touchPoint: CGPoint = touchPoint.location(in: mapView)
        let mapCoordinates: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        return mapCoordinates
    }
}


//MARK:- MKMAPView Delegate
extension LocationsMapViewController  {
    
    //track annotation view taps
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        //capture annotation tapped for sending to detinationVC
        annotationTapped = view.annotation
        
        //trigger segue
        performSegue(withIdentifier: SegueIdentifier.segueToPhotoAlbumViewController, sender: self)
        
        //trigger save of map region
        UserSettingsDataPersistenceManager.shared.saveMapRegion()
    }
    
    //track when the user moves the map and save the region
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        AppDelegate.region = mapView.region //set current region
    }
}
