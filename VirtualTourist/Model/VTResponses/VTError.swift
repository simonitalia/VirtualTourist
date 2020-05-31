//
//  VTErrorResponse.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation

struct VTError: Codable, Error {
    let status: String
    let code: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case status = "stat"
        case code
        case message
    }
}
