//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


struct SearchResult: Codable {
    let photo: Photo
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photo
        case status = "stat"
    }
}


struct Photo: Codable {
    let id: String
    let urls: [PhotoUrl]
}


struct PhotoUrl: Codable {
    let type: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case type
        case url = "_content"
    }
}

