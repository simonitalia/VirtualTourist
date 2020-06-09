//
//  PhotoAlbumDataViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/9/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import CoreData

class PhotoAlbumDataViewController: PhotoAlbumViewController {
    
    
    //MARK:- Data Persistence Properties
    //Core Data
    var dataController: DataController? {
        return DataController.shared
    }
    
    private var fetchedResultsController: NSFetchedResultsController<PhotoCollection>!
    
    
    private let pinIdentifier: String? = {
        guard let identifier = PhotoAlbumViewController.annotation?.subtitle else { return nil }
        print("Pin Identifier: \(String(describing: identifier))")
        return identifier
    }()
    
    
    //MARK: Data Manager
    override func displayPhotos(with photoCollection: PhotoCollection) {
        super.displayPhotos(with: photoCollection)
        updateCoreData(with: photoCollection)
    }
    
    
    //MARK:- Core Data
    private func updateCoreData(with collection: PhotoCollection) {
        print("starting database load...")
        dataController?.container.performBackgroundTask { [weak self] context in
            
            guard let identifier = self?.pinIdentifier else {
                print("Error! Unable to create new photo collection in Core Data. Pin identifier missing.")
                return
            }
            
            
            do {
                _ = try PhotoCollection.createPhotoCollection(for: collection, matching: identifier, in: context)
                print("Succes! Pin found in Core Data. Attaching to Photo Collection")
                try? context.save()
                
                print("done loading database...")
                self?.printCoreDataStatistics(context: context)
            
            } catch {
                print("Error! Fetching Pin from Core Data \(error.localizedDescription)")
            }
        }
    }
}
