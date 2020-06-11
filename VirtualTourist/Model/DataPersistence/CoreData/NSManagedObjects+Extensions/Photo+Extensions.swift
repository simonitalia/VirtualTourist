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
    
    class func fetchOrCreatePhoto(matching photo: Photo, for photoCollection: PhotoCollection, in context: NSManagedObjectContext) throws -> Photo {
        
        //lookup in core data
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", photo.id!)
        
        do {
            let photos = try context.fetch(request)
            if photos.count > 0 {
                assert(photos.count == 1, "Issue with Database. Fetched photos should be unique.")
//                print("Photo found in core data.")
                return photos[0] //return record, should only be 1 record
            }
        
        } catch {
            throw error //send error back to call site
        }
        
        
        print("Photo not found in core data. Creating new Photo.")
        
        //create new if not found
        let newPhoto = Photo(context: context)
        newPhoto.id = photo.id
        newPhoto.title = photo.title
        newPhoto.imageURL = photo.imageURL
        newPhoto.photoCollection = photoCollection
        
        //get and convert image to data
        if let urlString = photo.imageURL {
            Photo.fetchImage(from: urlString) { image in
                newPhoto.image = image.pngData()
                print("Photo image saved to Core Data")
            }
        }
        
        return newPhoto
    }
    
    
    class func fetchImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        VTNetworkController.shared.getPhotoImage(from: urlString) { (image) in
            if let image = image {
                completion(image)
            }
        }
    }
}
