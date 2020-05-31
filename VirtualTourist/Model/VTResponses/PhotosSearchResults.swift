//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


struct PhotosSearchResults: Codable {
    let photos: Photos
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photos
        case status = "stat"
    }
}


struct Photos: Codable {
    let photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case photos = "photo"
    }
}


struct Photo: Codable {
    let id: String
    let title: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "url_m" //medium size url
    }
}
