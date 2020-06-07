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

    //reference to container
    private var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    
    
    override func updateDataSource(with photoAlbum: PhotoCollection) {
        super.updateDataSource(with: photoAlbum)
        updateDatabase(with: photoAlbum)
    }
    
    
    private func updateDatabase(with photoAlbum: PhotoCollection) {
        print("Loading database started...")
        container?.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            for photoItem in photoAlbum.photoItems {
                
                do {
                    _ = try Photo.fetchPhoto(matching: photoItem, in: context)
                
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


//MARK:- Helpers
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
