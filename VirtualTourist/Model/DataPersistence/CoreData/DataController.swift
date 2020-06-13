//
//  DataController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    static let shared = DataController(modelName: "VirtualTourist")
    
    let container: NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return container.viewContext
    }
    
    let backgroundContext:NSManagedObjectContext!
    
    init(modelName:String) {
        container = NSPersistentContainer(name: modelName)
        
        backgroundContext = container.newBackgroundContext()
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContexts()
            completion?()
        }
    }
}

// MARK: - Autosaving

extension DataController {
    func autoSaveViewContext(interval:TimeInterval = 30) {
        
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            print("Changes detected in viewContext...autosaving core data.")
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
}

//MARK:- Print CoreData Stats

extension DataController {
    
    func printCoreDataStatistics() {
        viewContext.perform {
            if Thread.isMainThread {
                print("\nPerforming context task on... main thread.")
            } else {
                print("\nPerforming context task on... background thread.")
            }
            
            if let pins = try? self.viewContext.count(for: Pin.fetchRequest()) {
                print("Pins in core data: \(pins).")
            }
            
            if let collections = try? self.viewContext.count(for: PhotoCollection.fetchRequest()) {
                print("Collections in core data: \(collections).")
            }
            
            if let photos = try? self.viewContext.fetch(Photo.fetchRequest()) {
                print("Photos in core data: \(photos.count).")
            }
        }
    }
}
