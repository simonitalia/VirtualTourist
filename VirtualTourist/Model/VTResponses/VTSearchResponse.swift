//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


struct VTSearchResponse: Codable {
    var results: PhotoAlbumObject
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case results = "photos"
        case status = "stat"
    }
}


struct PhotoAlbumObject: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    var photos: [PhotoObject]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case photos = "photo"
    }
}


struct PhotoObject: Codable {
    let id: String
    let title: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "url_m" //medium size url
    }
}
