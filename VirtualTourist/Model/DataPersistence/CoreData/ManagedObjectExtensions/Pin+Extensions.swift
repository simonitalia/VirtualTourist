//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/9/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import MapKit
import CoreData

extension Pin {
    
    class func fetchOrCreatePin(matching annotation: MKAnnotation, in context: NSManagedObjectContext) throws -> Pin {
        
        //fetch existing pin
        if annotation.subtitle != "" {
            
            //lookup pin in database
            let request: NSFetchRequest<Pin> = Pin.fetchRequest()
            request.predicate = NSPredicate(format: "identifier = %@", annotation.subtitle!!)
            
            do {
                let pin = try context.fetch(request)
                if pin.count > 0 {
                    assert(pin.count == 1, "Database issue. Multiple pins with same identifer found")
                    print("Pin found in core data, returning existing pin...")
                    return pin[0]
                }
            } catch {
                throw error
            }
        }
        
        //if pin not found, vreate new pin
        print("Pin not found in core data, creating new pin...")
        
        let pin = Pin(context: context)
        pin.identifier = UUID().uuidString
        pin.locationName = annotation.subtitle ?? "Location unknown"
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        
        return pin
    }
}
