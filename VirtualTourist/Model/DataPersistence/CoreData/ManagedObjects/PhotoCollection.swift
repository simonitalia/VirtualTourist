//
//  PhotoCollection.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/9/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

class PhotoCollection: NSManagedObject, Decodable {
       
    //MARK:- Codable support
    
    //map json keys to nsmanaged object keys
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case photos = "photo"
        case total
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context else { fatalError("cannot find context key") }
        guard let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext else { fatalError("cannot Retrieve context") }
        guard let entity = NSEntityDescription.entity(forEntityName: "PhotoCollection", in: managedObjectContext) else { fatalError() }
        
        self.init(entity: entity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try container.decode(Int64.self, forKey: .page)
        self.pages = try container.decode(Int64.self, forKey: .pages)
        self.photos = NSSet(array: try container.decode([Photo].self, forKey: .photos)) //set as core data type nsset
        self.total = try container.decode(String.self, forKey: .total)
    }
    
    
    class func createPhotoCollection(for photoCollection: PhotoCollection, matching identifier: String, in context: NSManagedObjectContext) throws -> PhotoCollection {
        
        guard photoCollection.pin == nil else {
            fatalError("Error: Aborting creation of new Photo Collection. Pin already set for this collection")
        }
    
        let collection = PhotoCollection(context: context)
        collection.page = photoCollection.page
        collection.pages = photoCollection.pages
        collection.total = photoCollection.total
        collection.pin = try? Pin.fetchPin(matching: identifier, in: context)
        return collection
    }
    
    
    class func fetchPhotoCollection(for pin: Pin, in context: NSManagedObjectContext) throws -> PhotoCollection? {
        if let identifier = pin.identifier {
            let request: NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
            request.predicate = NSPredicate(format: "identifier = %@", identifier)
            
            do {
               let collection = try context.fetch(request)
               if collection.count > 0 {
                   assert(collection.count == 1, "Database issue. Multiple Photo Collections with same identifer found")
                   return collection[0]
               }
            } catch {
               throw error
            }
        }
        
        return nil
    }
}


