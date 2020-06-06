//
//  CoreDataPhotoViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/5/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

//this class manages data object interactions with core data
class CoreDataPhotoViewController: PhotoAlbumViewController {

    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    
    override func updateDataSource(with searchResponse: VTSearchResponse) {
        super.updateDataSource(with: searchResponse)
        updateDatabase(with: searchResponse)
    }
    
    
    private func updateDatabase(with searchResponse: VTSearchResponse) {
        print("Loading database started...")
        container?.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            for photoObject in searchResponse.results.photos {
                
                do {
                    _ = try Photo.fetchPhoto(matching: photoObject, in: context)
                
                } catch {
                     fatalError("Error! Fetch could not be performed: \(error.localizedDescription)")
                }
            }
            
            do {
                try context.save()
                print("...loading database finished")
                self.printDatabaseStats()
                
            } catch {
                fatalError("Error! Save could not be performed: \(error.localizedDescription)")
            }
        }
    }
}

extension CoreDataPhotoViewController {
    private func printDatabaseStats() {
        if let context = container?.viewContext {
            context.perform { //execute on safe queue
                let request: NSFetchRequest<Photo> = Photo.fetchRequest()
                if let photoCount = try? context.count(for: request) {
                    print("Photos currently in database: \(photoCount)")
                }
            }
        }
    }
}
