//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

struct SearchResponse: Decodable {
    var photoCollection: PhotoCollection
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photoCollection = "photos"
        case status = "stat"
    }
}
