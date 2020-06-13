//
//  UserSettingsDataPersistenceManager.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/2/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

//import Foundation
import MapKit


struct UserSettingsDataPersistenceManager {
    
    //MARK:- Class Properties
    static let shared = UserSettingsDataPersistenceManager()
    private let userDefaults = UserDefaults.standard
    
    private enum UserDefaultsKey {
        static let mapRegion = "MapRegion"
    }
    
    
    //private init
    private init() {}
    
    
    //MARK:- User Data Save / load methods
    func saveMapRegion() {
        guard let region = AppDelegate.region else { return }
        
        //convert map region to data
        guard let data = convertToDataFrom(region: region) else {
            print(VTError.unableToSaveMapRegion)
            return
        }
        
        //save data
        UserSettingsDataPersistenceManager.shared.userDefaults.set(data, forKey: UserDefaultsKey.mapRegion)
    }
    
    
    func loadMapRegion(completion: @escaping (Result<MKCoordinateRegion, VTError>) -> Void) {
        guard let data = UserSettingsDataPersistenceManager.shared.userDefaults.object(forKey: UserDefaultsKey.mapRegion) as? Data else {
            
            completion(.failure(.unableToLoadMapRegion))
            return
        }
        
        //decode data to map region
        if let region = convertToObjectFrom(data: data) {
//            print("Success! Loaded map region: \(region)")
            completion(.success(region))
            
        } else {
            completion(.failure(.unableToLoadMapRegion))
        }
    }
    
    
    private func convertToDataFrom(region: MKCoordinateRegion) -> Data? {
        
        //convert region to custom codable MapRegion
        let mapRegion = MapRegion(centerLatitude: region.center.latitude, centerLongitude: region.center.longitude, spanLatitude: region.span.latitudeDelta, spanLongitude: region.span.longitudeDelta)
        
        //encode as data
        let pListEncoder = PropertyListEncoder()
        if let data = try? pListEncoder.encode(mapRegion) {
            return data
        }
        
        return nil
    }
    
    
    private func convertToObjectFrom(data: Data) -> MKCoordinateRegion? {
        let pListDecoder = PropertyListDecoder()
        if let mapRegion = try? pListDecoder.decode(MapRegion.self, from: data) {
        
            //convert custom Region to region
            var region = MKCoordinateRegion()
            region.center.latitude = mapRegion.centerLatitude
            region.center.longitude = mapRegion.centerLongitude
            region.span.latitudeDelta = mapRegion.spanLatitude
            region.span.longitudeDelta = mapRegion.spanLongitude
            return region
        
        } else {
            return nil
        }
    }
}


