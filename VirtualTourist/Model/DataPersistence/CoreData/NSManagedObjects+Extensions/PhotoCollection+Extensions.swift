//
//  PhotoCollection+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//


import CoreData


extension PhotoCollection {
    
    class func fetchOrCreatePhotoCollection(matching pin: Pin, using photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoCollection {

        //lookup in core data
        let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
        request.predicate = NSPredicate(format: "pin = %@", pin)

        do {
           let collection = try context.fetch(request)
           if collection.count > 0 {
                assert(collection.count == 1, "Database issue. Multiple Photo Collections found.")
                print("Photo Collection found in core data.")
                return collection[0]
           }
        } catch {
           throw error
        }

        print("Photo Collection not found in core data. Creating new Photo Collection.")

        //create new if not found
        let newCollection = PhotoCollection(context: context)
        newCollection.page = photoCollection.page
        newCollection.pages = photoCollection.pages
        newCollection.total = photoCollection.total
        newCollection.pin = try? Pin.fetchPin(matching: pin, in: context)
        return newCollection
    }
    
    
//    class func fetchOrCreatePhotoCollection(matching photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoCollection {
//        guard let pin = photoCollection.pin else {
//            fatalError("Error! Photo Collection cannot be fetched. Pin is missing.")
//        }
//        
//        //lookup in core data
//        let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
//        request.predicate = NSPredicate(format: "pin = %@", pin)
//        
//        do {
//           let collection = try context.fetch(request)
//           if collection.count > 0 {
//                assert(collection.count == 1, "Database issue. Multiple Photo Collections found.")
//                print("Photo Collection found in core data.")
//                return collection[0]
//           }
//        } catch {
//           throw error
//        }
//        
//        print("Photo Collection not found in core data. Creating new Photo Collection.")
//        
//        //create new if not found
//        let newCollection = PhotoCollection(context: context)
//        newCollection.page = photoCollection.page
//        newCollection.pages = photoCollection.pages
//        newCollection.total = photoCollection.total
//        newCollection.pin = pin
//        return newCollection
//    }
}
