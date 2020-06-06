//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/5/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

class PhotoAlbum: NSManagedObject {

    class func fetchPhotoAlbum(matching photoAlbum: PhotoCollection, in context: NSManagedObjectContext) throws -> PhotoAlbum {
        let request: NSFetchRequest<PhotoAlbum> = PhotoAlbum.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", photoAlbum.id)
        
        //try to find requestd photo in core data
        do {
            let fetchedAlbum = try context.fetch(request)
            if fetchedAlbum.count > 0 {
                assert(fetchedAlbum.count == 1, "Issue with Database. fetched photos should be unique")
                return fetchedAlbum[0] //return record, should only be 1 record
            }
        
        } catch {
            throw error //send error back to call site
        }
        
        //create photo album in core data
        let album = PhotoAlbum(context: context)
        album.page = Int64(photoAlbum.page)
        album.pages = Int64(photoAlbum.pages)
        album.perPage = Int64(photoAlbum.perPage)
        album.total = photoAlbum.total
        album.photos = NSSet(object: photoAlbum.photoItems)
        album.identifier = photoAlbum.id
        
        return album
    }
}
