//
//  VTNetworkController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

class VTNetworkController {
    
    //MARK:- Core Data
    
    private var dataController: DataController? = {
        return DataController.shared
    }()
    
    
    //MARK:- Class Properties
    
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
            static let host = "www.flickr.com"
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
            static let page = "page"
            static let photosContentType = (key: "content_type", value: "1")
            static let responseFormatJSON = (key: "format", value: "json")
            static let imageUrllOriginal = (key: "extras", value: "url_o")
            static let imageUrllMedium = (key: "extras", value: "url_m")
            static let imageUrllSmall = (key: "extras", value: "url_s")
            static let imageUrlThumb = (key: "extras", value: "url_t")
        }
        
        //search method
        case searchBy(query: String)
        case searchByLocation(latitude: Double, longitude: Double, page: Int)
    
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
            
            case .searchByLocation(let latitude, let longitude, let page):
                var components = self.getURLComponents(appendingWith: URLPath.rest)
                components.queryItems = [
                    URLQueryItem(name: QueryParameter.method, value: APIMethod.Photos.search),
                    URLQueryItem(name: QueryParameter.apiKey.key, value: QueryParameter.apiKey.value),
                    URLQueryItem(name: QueryParameter.latitude, value: "\(latitude)"),
                    URLQueryItem(name: QueryParameter.longitude, value: "\(longitude)"),
                    URLQueryItem(name: QueryParameter.page, value: "\(page)"),
                    URLQueryItem(name: QueryParameter.photosContentType.key, value: QueryParameter.photosContentType.value),
                    URLQueryItem(name: QueryParameter.responseFormatJSON.key, value: QueryParameter.responseFormatJSON.value),
                    URLQueryItem(name: QueryParameter.imageUrllMedium.key, value: QueryParameter.imageUrllMedium.value) //get medium size image
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
    
    
    private init() {} //guard external initialization
    
    
    //general search by text
    func getPhotos(for text: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let url = Endpoint.searchBy(query: text).url else {
            print("Internal Error! Endpoint url could not be constructed.")
            return
        }
        print("EnpointUrl: \(url)") //to debug
    }
  
    
    func getPhotos(for pin: Pin, page: Int, completion: @escaping (Result<PhotoCollection, VTError>) -> Void) {
       guard let url = Endpoint.searchByLocation(latitude: pin.latitude, longitude: pin.longitude, page: page).url else {
           print("Internal Error! Endpoint url could not be constructed.")
           return
       }
       
       let request = URLRequest(url: url)
       let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
           
           //handle general error (eg: network error)
           if let error = error {
               print("Request Error! \(error.localizedDescription).")
               completion(.failure(.requestError))
               return
           }
           
           //bad http response
           guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200  else {
               print("httpResponse Error! \(error?.localizedDescription ?? "unknown error").")
               completion(.failure(.badHTTResponse))
               return
           }
           
           //no data returned
           guard let data = data else {
               completion(.failure(.invalidData))
               return
           }
           
           //handle successful data response
           do {
               let newData = self.newDataObject(from: data)
               let context = self.dataController?.container.viewContext
               
               let decoder = JSONDecoder()
               decoder.userInfo[CodingUserInfoKey.context!] = context

               //decode data
               do {
                   let results = try decoder.decode(SearchResponse.self, from: newData)
                   print("Success! Photos for location successfully fetched from remote server.")
                
                    do {
                        //update core data
                        if let photoCollection = try self.updateCoreData(for: pin, with: results.photoCollection) {
                            
                           //pass photo collection back to call site
                           completion(.success(photoCollection))
                           return
                        }
                        
                    } catch {
                        print("Error! Fetching Photo Collection from Core Data \(error.localizedDescription)")
                    }
                }
               
           } catch {
               //error response from server
               do {
                   let decoder = JSONDecoder()
                   let newData = self.newDataObject(from: data)
                   
                   //decode error response data
                   let serverError = try decoder.decode(VTError.VTServerErrorResponse.self, from: newData)
                   print("Server Error! Remote server reponded with error message: \(serverError.message)")
                   if let error = VTError(rawValue: serverError.message) {
                       completion(.failure(error))
                       return
                   }
                   
               } catch {
                   //error results decoding error
                   print("Decoding Error! Failed to decode server error response: \(error.localizedDescription).")
                   completion(.failure(.jsonDecodingError))
               }
           }
       }
       
       task.resume()
   }
    
    
    private func newDataObject(from data: Data) -> Data {
        
        //remove unneccessary characters from response
        let prefix = "jsonFlickrApi("
        let suffix = ")"
        let start = prefix.count
        let end = data.count - suffix.count
        let range = start..<end
        return data.subdata(in: range)
    }
    
    
    func getPhotoImage(for photo: Photo, completion: @escaping (Result<UIImage, VTError>) -> Void) {
        guard let urlString = photo.imageURL, let url = URL(string: urlString) else { return }
        
        //check cache for image, load if cached
//        let imageCacheKey = NSString(string: urlString)
//        if let image = CacheManager.shared.imageCache.object(forKey: imageCacheKey) {
//            completion(.success(image))
//            return
//        }

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

            //check for error
            if let error = error {
                print("Error fetching image: \(error.localizedDescription) ")
                
                completion(.failure(.unableToFetchPhoto))
                return
            }

            //check for server response code 200, else bail out
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.unableToFetchPhoto))
                return
            }

            if let data = data {
                guard let image = UIImage(data: data) else {
                    completion(.failure(.unableToFetchPhoto))
                    return
                }
                
                //update cache manager
//                CacheManager.shared.imageCache.setObject(image, forKey: imageCacheKey)
                
                //save image to core data
                self.updateCoreData(image: photo, with: data)
                
                //pass image back to caller
                completion(.success(image))
            }
        }

        task.resume()
    }
}


//MARK:- Core Data Helpers

extension VTNetworkController {
    
    private func updateCoreData(for pin: Pin, with photoCollection: PhotoCollection) throws -> PhotoCollection? {
        if let context = self.dataController?.container.viewContext {
            
            do {
                
            //fetch photo collection context
            let fetchedCollection = try PhotoCollection.fetchOrCreatePhotoCollection(matching: pin, using: photoCollection, in: context)
                
//            let fetchedCollection = PhotoCollection.createPhotoCollection(for: pin, using: photoCollection, in: context)
                
                //update saved page to fetched page
                fetchedCollection.page = photoCollection.page
                
                do {
                    //fetch photos context
                    for photo in photoCollection.photos as! Set<Photo> {
                        _ = try Photo.fetchOrCreatePhoto(matching: photo, for: fetchedCollection, in: context)
                        
                        try? dataController?.container.viewContext.save()
//                        dataController?.printCoreDataStatistics()
                    }

                } catch {
                    print("Error! Fetching Photo from Core Data \(error.localizedDescription)")
                }
                
                try? dataController?.container.viewContext.save()
                dataController?.printCoreDataStatistics()
                
                return fetchedCollection
            
            } catch {
                throw error
            }
        }
        
        return nil
    }
    
    
    private func updateCoreData(image photo: Photo, with data: Data) {
        if let context = self.dataController?.container.viewContext {
            
            do {
                if let photo = try Photo.fetchPhoto(matching: photo, in: context) {
                    photo.image = data
                }
   
                try? dataController?.container.viewContext.save()
//                dataController?.printCoreDataStatistics()
                
            } catch {
                 print("Error! Fetching Photo from Core Data \(error.localizedDescription)")
            }
        }
    }
}
