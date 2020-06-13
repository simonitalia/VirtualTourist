//
//  PhotoAlbumCollectionViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/10/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit


class PhotoAlbumMasterViewController: UIViewController {
    
    //MARK:- Class Properties
    //shared bewteen applicable PhotoAlbumVCs
    static var pin: Pin? {
        didSet {
            guard let pin = pin else { return }
            switch pin.photoCollection {
            case nil:
                print("\nPin photoCollection is nil")
                
            default:
                print("\nPin photoCollection not nil")
                break
            }
        }
    }
}
