//
//  VTErrorResponse.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/30/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import Foundation


//custom error messages
enum VTError: String, Error {
    case badHTTResponse = "Remote server responded with http error status."
    case requestError = "We encountered an error. Please try again."
    case invalidData = "Remote server returned invalid data." //no data returned
    case jsonDecodingError = "Failed to parse json data returned from server."
    case unableToLoadMapRegion = "Unable to load map region from user defaults."
    case unableToSaveMapRegion = "Unable to save map region to user defaults."
    case unableToDownloadPhoto = "We encountered a problem while downloading photo."
}


//server error response definition
extension VTError: Decodable {
    struct VTServerErrorResponse: Decodable, Error {
        let status: String
        let code: Int
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case status = "stat"
            case code
            case message
        }
    }
}
