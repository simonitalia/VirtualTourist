//
//  VTResponses.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


struct SearchResponse: Codable {
    let results: Results
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case results = "photos"
        case status = "stat"
    }
}


struct Results: Codable {
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let Items: [Item]
    
    enum CodingKeys: String, CodingKey {
        case page
        case pages
        case perPage = "perpage"
        case total
        case Items = "photo"
    }
}


struct Item: Codable {
    let id: String
    let title: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "url_m" //medium size url
    }
}
