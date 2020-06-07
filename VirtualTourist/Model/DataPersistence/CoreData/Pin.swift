//
//  Pin.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/6/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class Pin: NSManagedObject {
    
    class func fetchOrCreatePin(using annotation: MKAnnotation, in context: NSManagedObjectContext) throws -> Pin {
        guard let identifier = annotation.subtitle else {
            fatalError("Error! Annotation identifier should not be nil")
        }
        
        //lookup pin in database
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier!)
        
        do {
            let pin = try context.fetch(request)
            if pin.count > 0 {
                assert(pin.count == 1, "Database issue. Multiple pins with same identifer found")
                return pin[0]
            }
        } catch {
            throw error
        }
        
        //if pin not found, vreate new pin
        let newPin = Pin(context: context)
        
        if let title = annotation.title {
            newPin.locationName = title
        } else {
            newPin.locationName = "Location unknown"
        }
        
        if let subtitle = annotation.subtitle {
            newPin.identifier = subtitle
        }
        
        newPin.latitude = annotation.coordinate.latitude
        newPin.longitude = annotation.coordinate.longitude
        return newPin
    }
}
