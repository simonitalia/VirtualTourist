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
}


