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
    
    class func fetchPhoto(matching photo: Photo, in context: NSManagedObjectContext) throws -> Photo {
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", photo.id!)
        
        do {
            let photos = try context.fetch(request)
            if photos.count > 0 {
                assert(photos.count == 1, "Issue with Database. Fetched photos should be unique.")
                print("Photo found in core data.")
                return photos[0] //return record, should only be 1 record
            }
        
        } catch {
            throw error //send error back to call site
        }
        
        return photo
    }
    
    
    class func fetchImage(from urlString: String, completion: @escaping (UIImage) -> Void) {
        VTNetworkController.shared.getPhotoImage(from: urlString) { (image) in
            if let image = image {
                completion(image)
            }
        }
    }
}
