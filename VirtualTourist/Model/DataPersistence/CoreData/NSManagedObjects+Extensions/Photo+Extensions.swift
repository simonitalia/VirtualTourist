//
//  Photo+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/11/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import CoreData
import UIKit


extension Photo {
    
    //called when new search results retrieved
    class func fetchOrCreatePhoto(matching photo: Photo, for photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> Photo {

        //lookup in core data
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", photo.id!)

        do {
            let photos = try context.fetch(request)
            if photos.count > 0 {
                assert(photos.count == 1, "Issue with Database. Fetched photos should be unique.")
//                print("Success! Photo found in core data.")
                return photos[0] //return record, should only be 1 record
            }

        } catch {
            throw error //send error back to call site
        }

        //create new if not found
//        print("Photo not found in core data, creating new Photo.")
        let newPhoto = Photo(context: context)
        newPhoto.id = photo.id
        newPhoto.title = photo.title
        newPhoto.imageURL = photo.imageURL
        newPhoto.image = photo.image
        newPhoto.photoCollection = photoCollection //entity relationship
        return newPhoto
    }
    
    
    //called when setting photo image
    class func fetchPhoto(matching photo: Photo, in context: NSManagedObjectContext) throws -> Photo? {
        guard let id = photo.id else {
            return nil
        }
        
        //lookup in core data
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)

        do {
            let photos = try context.fetch(request)
            if photos.count > 0 {
                assert(photos.count == 1, "Issue with Database. Fetched photos should be unique.")
//                print("Success! Photo found in core data.")
                return photos[0] //return record, should only be 1 record
            }

        } catch {
            throw error //send error back to call site
        }
        
        return nil
    }
    
    
    //purge photos from core data
    class func delete(photos: [Photo], in context: NSManagedObjectContext) throws {
        photos.forEach { context.delete($0) }
        
        do {
            try context.save()
            
        } catch {
            throw error
        }
    }
}
