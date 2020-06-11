//
//  UIMapView+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/31/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import MapKit


extension MKMapView {
    
    //user derived annotation
    func createMapPointAnnotation(from mapCoordinate: CLLocationCoordinate2D) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = mapCoordinate
        
        //set title to placemark locality name
        getPlacemark(for: mapCoordinate) { placemark in
            if let placemark = placemark {
                annotation.title = placemark.locality
            }
        }
        
        return annotation
    }
    
    
    //core data derived annotation
    func createMapPointAnnotation(from pin: Pin) -> MKAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.title = pin.locationName
        annotation.subtitle = pin.identifier
        return annotation
    }
    
    
    //core data derived annotations
    func createMapPointAnnotations(from pins: [Pin]) -> [MKAnnotation] {
        var annotations = [MKAnnotation]()
        
        pins.forEach {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            annotation.title = $0.locationName
            annotation.subtitle = $0.identifier
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    
    //add multiple annotation to mapView
    func updateMapView(with annotations: [MKAnnotation]) {
        DispatchQueue.main.async {
            self.addAnnotations(annotations)
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


