//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


struct PhotosSearchResults: Codable {
    var photosResponse: PhotosResponse
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case photosResponse = "photos"
        case status = "stat"
    }
}


struct PhotosResponse: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    var photos: [Photo]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
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
