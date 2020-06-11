//
//  PhotoAlbumDataViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/9/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import CoreData

class PhotoAlbumCollectionDataViewController: PhotoAlbumCollectionViewController {
    
    
    //MARK:- Data Persistence Properties
    //Core Data
    var dataController: DataController? {
        return DataController.shared
    }
    
    private var fetchedResultsController: NSFetchedResultsController<PhotoCollection>!
    
    
    //MARK:- Class properties
    private let pin: Pin? = {
        return PhotoAlbumMasterViewController.pin
    }()
    

    //MARK: Data Manager
    override func displayPhotos(with photoCollection: PhotoCollection) {
        super.displayPhotos(with: photoCollection)
        updateCoreData(with: photoCollection)
    }
    
}


//MARK:- Core Data Helpers
extension PhotoAlbumCollectionDataViewController {
    
    private func updateCoreData(with photoCollection: PhotoCollection) {
        print("starting database load...")
        
        guard let pin = self.pin, let photos = photoCollection.photos else {
            print("Error! Unable to create new photo collection in Core Data. Pin identifier missing.")
            return
        }
        
        if let context = dataController?.container.viewContext {
            do {
                           
                //set fetched photo collection album in core data
                let fetchedCollection = try PhotoCollection.fetchOrCreatePhotoCollection(matching: pin, using: photoCollection, in: context)
               
                //set photos in core data
                if let photos = self.convertNSSetPhotosToArray(photos: photos) {
                   for photo in photos {
                       _ = try Photo.fetchOrCreatePhoto(matching: photo, for: fetchedCollection, in: context)
                   }
               }

               //save to core data
               print("Success! Pin fetched from Core Data. Attaching Photo Collection.")
               print("done loading database...")
                self.updateCoreData(context: context)

           } catch {
               print("Error! Fetching Pin from Core Data \(error.localizedDescription)")
           }
        }
    }
}

