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
    
    private var searchResults: PhotosSearchResults!
    private var photos: [Photo] {
        get {
            guard let results = searchResults else { return [] }
            return results.photosResponse.photos
        }
        
        set { return }
    }
        
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateView: UIView!
    

    //actions
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        guard searchResults != nil else { return }
        guard searchResults.photosResponse.pages > 1 else {
            self.presentUserAlert(with: "No More Photos", and: "There are no other photos for this location.")
            return
        }
        
        performGetPhotos(forPage: getRandomPage())
    }
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !emptyStateView.isHidden {
            self.setEmptyStateView(false)
        }
    }
    
    
    //MARK:- ViewController Setup
    private func configureVC() {
        configureCollectionView()
    }
    
    
    private func configureUI() {
        DispatchQueue.main.async {
            
            //if photos
            switch self.photos.isEmpty {
            case false:
                self.photoAlbumCollectionView.reloadData()
            
                //if no photos, show empty state view
            case true:
                self.setEmptyStateView(true)
            }
        }
    }
    
    
    private func configureCollectionView() {
        //setup layout
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
        
        //trigger fetch of photos
        performGetPhotos()
    }
    
    
    private func performGetPhotos(forPage number: Int=1) {
        guard let annotation = PhotoAlbumViewController.annotation else { return }
        
        //show / start animating activity indicator
        collectionViewActivityIndicator(animate: true)
        
        let lat = annotation.coordinate.latitude
        let lon = annotation.coordinate.longitude
        
        VTNetworkController.shared.getPhotos(for: (lat: lat, lon: lon), page: number) { [weak self] result in
            guard let self = self else { return }
            
            //stop / hide animating activity indicator
            self.collectionViewActivityIndicator(animate: false)
            
            switch result {
            case .success(let searchResults):
                self.searchResults = searchResults
                print("Photos page: \(searchResults.photosResponse.page) of \(searchResults.photosResponse.pages)")
                self.configureUI()
                
            case .failure(let error):
                self.presentUserAlert(with: "Something went wrong", and: error.rawValue)
            }
        }
    }
}


//MARK: CollectionView Delegate
extension PhotoAlbumViewController: UICollectionViewDelegate {
    
    //support deleting item in collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        searchResults.photosResponse.photos.remove(at: indexPath.item)
        photoAlbumCollectionView.deleteItems(at: [indexPath])
        
        //display empty state
        if photos.isEmpty && searchResults.photosResponse.pages < 2 {
            self.setEmptyStateView(true)
        }
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
        let photo = photos[indexPath.item]
        
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
    
    
    private func setEmptyStateView(_ display: Bool) {
        DispatchQueue.main.async {
            self.emptyStateView.isHidden = !display
            self.photoAlbumCollectionView.isHidden = display
        }
    }
    
    
    private func getRandomPage() -> Int {
        let currentPage = searchResults.photosResponse.page
        let pageRange = 1...searchResults.photosResponse.pages
        var randomPage = Int.random(in: pageRange)
        
        while randomPage == currentPage {
            randomPage = getRandomPage()
        }

        return randomPage
    }
    
}
