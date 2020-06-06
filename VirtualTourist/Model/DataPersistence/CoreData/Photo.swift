//
//  Photo.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/5/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject {
    
    class func fetchPhoto(matching photoItem: PhotoItem, in context: NSManagedObjectContext) throws -> Photo {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", photoItem.id)
        
        //try to find requestd photo in core data
        do {
            let fetchedPhotos = try context.fetch(request)
            if fetchedPhotos.count > 0 {
                assert(fetchedPhotos.count == 1, "Issue with Database. fetched photos should be unique")
                return fetchedPhotos[0] //return record, should only be 1 record
            }
        
        } catch {
            throw error //send error back to call site
        }
        
        //create photo in core data
        let photo = Photo(context: context)
        photo.id = photoItem.id
        photo.imageURL = photoItem.imageURL
        photo.title = photoItem.title
//        photo.image = Data(photoItem.image)
       
        return photo
    }
    
}
