//
//  PhotoCollection+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//


import CoreData


extension PhotoCollection {
    
    
    class func createPhotoCollection(for pin: Pin, using photoCollection: PhotoCollection, in context: NSManagedObjectContext) -> PhotoCollection {
        
        let newCollection = PhotoCollection(context: context)
        newCollection.pin = pin //entity relationship
        newCollection.page = photoCollection.page
        newCollection.pages = photoCollection.pages
        newCollection.total = photoCollection.total
        return newCollection
    }
    
    
    class func fetchOrCreatePhotoCollection(matching pin: Pin, using photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoCollection {

        //lookup in core data
        let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
        request.predicate = NSPredicate(format: "photoCollection = %@", photoCollection)

        do {
           let collection = try context.fetch(request)
           if collection.count > 0 {
                assert(collection.count == 1, "Database issue. Multiple Photo Collections found.")
                print("Success! Photo Collection found in core data. Attaching to Pin.")
                return collection[0]
           }
        } catch {
           throw error
        }

        print("Photo Collection not found in core data. Creating new Photo Collection.")

        //create new if not found
        let newCollection = PhotoCollection(context: context)
        newCollection.pin = pin //entity relationship
        newCollection.page = photoCollection.page
        newCollection.pages = photoCollection.pages
        newCollection.total = photoCollection.total
        return newCollection
    }
}
