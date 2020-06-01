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
    
    private var photos = [Photo]()
    
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
    

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
        photoAlbumCollectionView.delegate = self
        photoAlbumCollectionView.dataSource = self
        configureCollectionView()
    }
    
    
    private func configureUI() {
        DispatchQueue.main.async {
            self.photoAlbumCollectionView.reloadData()
        }
    }
    
    
    private func configureCollectionView() {
        //setup layout
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
        
        //trigger fetch of photos
        performGetPhotos()
    }
    
    
    private func performGetPhotos() {
        guard photos.isEmpty else { return }
        guard let annotation = PhotoAlbumViewController.annotation else { return }
        
        //show / start animating activity indicator
        collectionViewActivityIndicator(animate: true)
        
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        VTNetworkController.shared.getPhotos(for: (lat: lat, lon: lon)) { [weak self] result in
            guard let self = self else { return }
            
            //stop / hide animating activity indicator
            self.collectionViewActivityIndicator(animate: false)
            
            switch result {
            case .success(let searchResults):
                self.photos = searchResults.photos.photos
                self.configureUI()
                
            case .failure(let error):
                print(error.rawValue)
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

        //get photo object
        let photo = photos[indexPath.row]
        
        //configure cell
        let cell = photoAlbumCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        
        //set cell to placeholder image whilst real photo image downloads
        if let image = UIImage(named: "camera-outline") {
            cell.setPhotoImageView(with: image)
        }
        
        //fetch photo image and set to cell
        let imageURL = photo.imageURL
        cell.performGetPhotoImage(from: imageURL)
    
        return cell
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
    
    
    //set view UI elements state
    private func collectionViewActivityIndicator(animate: Bool) {
        
        DispatchQueue.main.async {
            self.collectionViewActivityIndicator.isHidden = !animate
            self.newCollectionButton.isEnabled = !animate
            animate ? self.collectionViewActivityIndicator.startAnimating() : self.collectionViewActivityIndicator.stopAnimating()
        }
    }
}
