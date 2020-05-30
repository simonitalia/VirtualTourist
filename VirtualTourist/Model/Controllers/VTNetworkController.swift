//
//  VTNetworkController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class VTNetworkController {
    
    //accessible class properties
    static var shared = VTNetworkController()
    
    //private class propeeties
    private enum httpMethod: String {
        case get = "GET"
    }
    
    private enum Endpoint {
        enum APIMethod {
            enum Photos {
                static let search = "flickr.photos.search"
            }
        }
        
        //url components
        enum URLComponent {
            static let scheme = "https"
            static let host = "https://www.flickr.com"
        }
        
        //api endpoint paths
        enum URLPath {
            static let rest = "/services/rest"
        }
        
        //api endpoint query items
        enum QueryParameter {
            static let method = "method"
            static let apiKey = (key: "api_key", value: "350ce3759924a6a223d12eb1afd8c9b4")
            static let text = "text"
            static let latitude = "lat"
            static let longitude = "lon"
            static let photosContentType = (key: "content_type", value: "1")
            static let responseFormatJSON = (key: "format", value: "json")
            static let imageUrllOriginal = (key: "extras", value: "url_o")
            static let imageUrllMedium = (key: "extras", value: "url_m")
            static let imageUrllSmall = (key: "extras", value: "url_s")
            static let imageUrlThumb = (key: "extras", value: "url_t")
        }
        
        //search method
        case searchBy(query: String)
        case searchByLocation(latitude: Double, longitude: Double)
    
        //compute endpoint url
        var url: URL? {
            switch self {
            case .searchBy(let query):
                var components = self.getURLComponents(appendingWith: URLPath.rest)
                components.queryItems = [
                    URLQueryItem(name: QueryParameter.method, value: APIMethod.Photos.search),
                    URLQueryItem(name: QueryParameter.apiKey.key, value: QueryParameter.apiKey.value),
                    URLQueryItem(name: QueryParameter.text, value: "\(query)"),
                    URLQueryItem(name: QueryParameter.photosContentType.key, value: QueryParameter.photosContentType.value),
                    URLQueryItem(name: QueryParameter.responseFormatJSON.key, value: QueryParameter.responseFormatJSON.value),
                    URLQueryItem(name: QueryParameter.imageUrllMedium.key, value: QueryParameter.imageUrllMedium.value)
                ]
                
                return components.url
            
            case .searchByLocation(let latitude, let longitude):
                var components = self.getURLComponents(appendingWith: URLPath.rest)
                components.queryItems = [
                    URLQueryItem(name: QueryParameter.method, value: APIMethod.Photos.search),
                    URLQueryItem(name: QueryParameter.apiKey.key, value: QueryParameter.apiKey.value),
                    URLQueryItem(name: QueryParameter.latitude, value: "\(latitude)"),
                    URLQueryItem(name: QueryParameter.longitude, value: "\(longitude)"),
                    URLQueryItem(name: QueryParameter.photosContentType.key, value: QueryParameter.photosContentType.value),
                    URLQueryItem(name: QueryParameter.responseFormatJSON.key, value: QueryParameter.responseFormatJSON.value),
                    URLQueryItem(name: QueryParameter.imageUrllMedium.key, value: QueryParameter.imageUrllMedium.value)
                ]
                
                return components.url
            }
        }
        
        //construct base URL from url components
        func getURLComponents(appendingWith path: String) -> URLComponents {
            var components = URLComponents()
            components.scheme = URLComponent.scheme
            components.host = URLComponent.host
            components.path = path
            return components
        }
    }
    
    
    //general search by text
    func getPhotos(for text: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = Endpoint.searchBy(query: text).url else {
            print("Internal Error! Endpoint url could not be constructed.")
            return
        }
        print("EnpointUrl: \(url)") //to debug
    }
    
    
    //search by lat / lon coordinates
    func getPhotosForLocation(for location: (lat: Double, lon: Double), completion: @escaping (Result<Bool, Error>) -> Void) {
        
        guard let url = Endpoint.searchByLocation(latitude: location.lat, longitude: location.lon).url else {
            print("Internal Error! Endpoint url could not be constructed.")
            return
        }
        
        print("EnpointUrl: \(url)") //to debug
        
        
        
        
        
        
    }
    
    
    func downloadPhotoImage(from url: String) -> UIImage {
        
        
        
        return UIImage()
        
    }
    
    
}
