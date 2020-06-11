//
//  PhotoCollection+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//


import CoreData


extension PhotoCollection {
    
    class func fetchOrCreatePhotoCollection(matching pin: Pin, with photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoCollection {
        
//        guard let identifier = pin.identifier else {
//            fatalError("Error: Photo Collection for Pin cannot be fetched or created. Pin identifier is missing.")
//        }
        
        
        //lookup in database
        let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
//        request.predicate = NSPredicate(format: "pin.identifier = %@", identifier)
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
        let collection = PhotoCollection(context: context)
        collection.page = photoCollection.page
        collection.pages = photoCollection.pages
        collection.total = photoCollection.total
//        collection.pin = try? Pin.fetchPin(matching: identifier, in: context)
        collection.pin = try? Pin.fetchPin(matching: pin, in: context)
        
        //loop through photos and set image
        if let photos = collection.photos?.allObjects as? [Photo] {
            for photo in photos {
                if let urlString = photo.imageURL {
                    Photo.fetchImage(from: urlString) { image in
                        photo.image = image.jpegData(compressionQuality: 1.0)
                        print("Photo image saved to Core Data")
                    }
                }
            }
        }
        
        return collection
    }
}
