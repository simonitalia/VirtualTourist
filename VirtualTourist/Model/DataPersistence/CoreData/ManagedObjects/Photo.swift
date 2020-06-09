//
//  Photo.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/9/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

class Photo: NSManagedObject, Codable {
    
    //MARK:- Codable support
    
    //map json keys to nsmanaged object keys
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "url_m"
        case image
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        guard let contextUserInfoKey = CodingUserInfoKey.context else { fatalError("cannot find context key") }
        guard let managedObjectContext = decoder.userInfo[contextUserInfoKey] as? NSManagedObjectContext else { fatalError("cannot Retrieve context") }
        guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: managedObjectContext) else { fatalError() }
        
        self.init(entity: entity, insertInto: nil)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
    }
    
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.title, forKey: .title)
        try container.encode(self.imageURL, forKey: .imageURL)
        try container.encodeIfPresent(self.image, forKey: .image)
    }
}
