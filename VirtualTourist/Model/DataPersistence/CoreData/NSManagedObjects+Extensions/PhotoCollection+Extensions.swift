//
//  PhotoCollection+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//


import CoreData


extension PhotoCollection {

    class func fetchOrCreatePhotoCollection(pin: Pin, using photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoCollection {
        
        guard let identifier = pin.identifier else {
            fatalError("Error! Photo Collection cannot be created for Pin. Pin is missing.")
        }

        //lookup in core data
        let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
        request.predicate = NSPredicate(format: "pin.identifier = %@", identifier)

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

        //create new if not found
        print("Photo Collection not found in core data, creating new Photo Collection.")

        let newCollection = PhotoCollection(context: context)
        newCollection.pin = pin //entity relationship
        newCollection.page = photoCollection.page
        newCollection.pages = photoCollection.pages
        newCollection.total = photoCollection.total
        return newCollection
    }
}
