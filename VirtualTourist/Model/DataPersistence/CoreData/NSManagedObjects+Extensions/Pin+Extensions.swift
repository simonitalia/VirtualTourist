//
//  Pin+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import CoreData
import MapKit


extension Pin {
    
    class func createPin(with annotation: MKAnnotation, in context: NSManagedObjectContext) -> Pin {
        let pin = Pin(context: context)
        pin.identifier = UUID().uuidString
        pin.locationName = annotation.subtitle ?? "Location unknown"
        pin.latitude = annotation.coordinate.latitude
        pin.longitude = annotation.coordinate.longitude
        return pin
    }
    
    
    //lookup used by LocationsMapVC
    class func fetchPin(matching identifier: String, in context: NSManagedObjectContext) throws -> Pin? {
        guard identifier != "" else {
            fatalError("Error! Pin cannot be fetched. Identifier is missing.")
        }
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)

        do {
            let pin = try context.fetch(request)
            if pin.count > 0 {
                assert(pin.count == 1, "Database issue. Multiple pins with same identifer found.")
                print("Pin found in core data.")
                return pin[0]
            }
        } catch {
            throw error //pass back error
        }

        print("Pin not found in core data.")
        return nil
    }
    
    
    //lookup used by PhotoAlbumCollectionDataVC
    class func fetchPin(matching pin: Pin, in context: NSManagedObjectContext) throws -> Pin? {
        guard let identifier = pin.identifier else {
            fatalError("Error! Pin cannot be fetched. Identifier is missing.")
        }
        
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()
        request.predicate = NSPredicate(format: "identifier = %@", identifier)

        do {
            let pin = try context.fetch(request)
            if pin.count > 0 {
                assert(pin.count == 1, "Database issue. Multiple Pins with unique identifer found.")
                print("Pin found in core data.")
                return pin[0]
            }
        } catch {
            throw error //pass back error
        }

        print("Pin not found in core data.")
        return nil
    }
}
