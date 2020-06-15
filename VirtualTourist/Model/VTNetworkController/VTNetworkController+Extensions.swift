//
//  VTNetworkController+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/15/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation
import CoreData


//MARK: - Core Data Helpers

extension VTNetworkController {
    
    func updateCoreData(for pin: Pin, with photoCollection: PhotoCollection) throws -> Pin? {
        if let context = self.dataController?.container.viewContext {
            
            //create new photo collection
            do {
                
                let fetchedCollection = try PhotoCollection.fetchOrCreatePhotoCollection(pin: pin, using: photoCollection, in: context)
                
                do {
                    
                    //fetch photos context
                    for photo in photoCollection.photos as! Set<Photo> {
                        _ = try Photo.fetchOrCreatePhoto(matching: photo, for: fetchedCollection, in: context)
                    }

                    try? context.save()
                    dataController?.printCoreDataStatistics()
                    return pin
                
                } catch {
                     print("Error! Failed to create new photos for for photo collection, \(error.localizedDescription)")
                }
                
            } catch {
                print("Error! Fetching or creating Photo Collection, \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    
    func updateCoreData(image photo: Photo, with data: Data) {
        if let context = self.dataController?.container.viewContext {
            
            do {
                if let photo = try Photo.fetchPhoto(matching: photo, in: context) {
                    photo.image = data
                    try? context.save()
                }
   
            } catch {
                 print("Error! Fetching Photo from Core Data \(error.localizedDescription)")
            }
        }
    }
}


//MARK: - Helpers

extension VTNetworkController {
    
    func newDataObject(from data: Data) -> Data {
        
        //remove unneccessary characters from response
        let prefix = "jsonFlickrApi("
        let suffix = ")"
        let start = prefix.count
        let end = data.count - suffix.count
        let range = start..<end
        return data.subdata(in: range)
    }
}
