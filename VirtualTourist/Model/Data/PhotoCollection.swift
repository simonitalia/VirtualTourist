//
//  PhotoAlbumObject.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/6/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

struct PhotoCollection {
    let id = UUID().uuidString
    let page: Int
    let pages: Int
    let perPage: Int
    let total: String
    let photoItems: [PhotoItem]

    init(_ searchResults: Results, photoItems: [PhotoItem]) {
        page = searchResults.page
        pages = searchResults.pages
        perPage = searchResults.perPage
        total = searchResults.total
        self.photoItems = photoItems
    }
}


struct PhotoItem {
    let id: String
    let title: String
    let imageURL: String
    var image = UIImage(named: "no-image-outline")
    
    init(_ item: Item) {
        id = item.id
        title = item.title
        imageURL = item.imageURL
    }
}





