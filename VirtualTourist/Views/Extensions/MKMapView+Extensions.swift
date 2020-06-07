//
//  UIMapView+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/31/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import MapKit


extension MKMapView {
    func setMapPointAnnotation(at coordinates: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        
        //set title to placemark locality name
        getPlacemark(for: coordinates) { placemark in
            if let placemark = placemark {
                annotation.title = placemark.locality
            }
        }
        
        //set subititle to unique identifier
        annotation.subtitle = UUID().uuidString
        
        //add annotation to map view
        DispatchQueue.main.async {
            self.addAnnotation(annotation) //done on main thread so pins appear on view/map load
        }
    }
    
    
    //search / get pin location meta data
    private func getPlacemark(for location: CLLocationCoordinate2D, completion: @escaping (CLPlacemark?) -> Void) {
        
    let geocoder = CLGeocoder()
        let searchLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(searchLocation) { (placemarks, error) in
            
            if let error = error {
                print("Unable to Reverse geocode location (\(error))")
                
            } else {
                if let placemarks = placemarks {
                    print("Pin locality found: \(placemarks.first?.locality ?? "Locality unknown").")
                    completion(placemarks.first)

                } else {
                    print("No matching placemark found.")
                }
            }
        }
    }
}

