//
//  PhotoAlbumMasterViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    //MARK:- Class Properties
    private let cellIdentifier = "PhotoCell"
    static var annotation: MKAnnotation!
    
    private var photos: [Photo] {
        return VTNetworkController.shared.photos
    }
    

    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    

    //actions
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        
    }
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    
    //MARK:- ViewController Setup
    private func configureVC() {
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        // Register cell classes
        self.photoAlbumCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        //setup layout
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
        
        //trigger fetch of photos
        performGetPhotos()
    }
    
    
    private func performGetPhotos() {
        guard let annotation = PhotoAlbumViewController.annotation else { return }
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.latitude
        VTNetworkController.shared.getPhotos(for: (lat: lat, lon: lon)) { (success, error) in
            
            if let _ = success {
                
            }
            
            if let _ = error {
                
            }
        }
    }
}


//MARK: CollectionView Delegate
extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }


    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }


    
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
}


//MARK: CollectionView Data Source
extension PhotoAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
//        let cell = UICollectionViewCell() as! PhotoAlbumCollectionViewCell
//        return cell
        return UICollectionViewCell()
    }
}


// MARK:- Helpers
extension PhotoAlbumViewController {
    
    //collection view layout setup
    private func configureCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.fractionalWidth(1.0), heightDimension: NSCollectionLayoutDimension.absolute(105)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),  heightDimension: .absolute(100))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            return section
        }
        
        return layout
    }
}
