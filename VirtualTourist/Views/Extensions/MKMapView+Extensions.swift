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

        //add annotation to map view
        DispatchQueue.main.async {
            self.addAnnotation(annotation) //done on main thread so pins appear on view/map load
        }
    }
}

