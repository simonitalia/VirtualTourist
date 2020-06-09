//
//  UIViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/31/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//


import MapKit
import CoreData


extension UIViewController {
    
    func presentUserAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
}


//MARK:- MapView Delegate
extension UIViewController: MKMapViewDelegate  {

    //cretaes and sets pin views on map when annotations added to map view
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let reuseID = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = false
        } else {
            pinView!.annotation = annotation
        }

        return pinView
    }
}


//MARK: CoreData
extension UIViewController {
    func printCoreDataStatistics(context: NSManagedObjectContext) {
        context.perform {
            if Thread.isMainThread {
                print("on main thread")
            } else {
                print("off main thread")
            }
            
            if let pins = try? context.count(for: Pin.fetchRequest()) {
                print("\nPins in core data: \(pins).")
            }
            
            if let collections = try? context.count(for: PhotoCollection.fetchRequest()) {
                print("\nCollections in core data: \(collections).")
            }
            
            if let photos = try? context.count(for: Photo.fetchRequest()) {
                print("\nPhotos in core data: \(photos).")
            }
        }
    }
}
