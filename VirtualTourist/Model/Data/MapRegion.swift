//
//  MapRegion.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/2/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

struct MapRegion: Codable {
    let centerLatitude: Double
    let centerLongitude: Double
    let spanLatitude: Double
    let spanLongitude: Double
}
