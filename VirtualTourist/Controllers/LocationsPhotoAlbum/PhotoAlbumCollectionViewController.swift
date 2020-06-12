//
//  PhotoAlbumMasterViewController.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/29/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumCollectionViewController: PhotoAlbumMasterViewController {
    
    //MARK:- Data Persistence Properties
    //Core Data
//    var dataController: DataController? {
//        return DataController.shared
//    }
    
    private var fetchedResultsController: NSFetchedResultsController<PhotoCollection>!
    
    
    //MARK:- Class Properties
    private let cellIdentifier = "PhotoCell"
    
    private var pin: Pin? {
        return PhotoAlbumMasterViewController.pin
    }
    
    private var photoCollection: PhotoCollection! {
        didSet {
            //configure UI
        }
    }
    
    
    private var photos: [Photo]! {
        get {
            guard let collection = photoCollection, let photos = collection.photos else { return [] }
            return convertNSSetPhotosToArray(photos: photos)
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
        guard photoCollection != nil else { return }
        guard photoCollection.pages > 1 else {
            self.presentUserAlert(title: "No More Photos", message: "There are no other photos for this location.")
            return
        }
        
        performGetPhotos(forPage: getRandomPage())
    }
    
    
    //MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureVC()
        configureCoreData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {}
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !emptyStateView.isHidden {
            self.setEmptyStateView(false)
        }
        
        fetchedResultsController = nil
    }
    
    
    //MARK:- Core Data Setup
    private func configureCoreData() {
//        congifureFetchedResultsController()
    }
    
    
    //MARK:- ViewController Setup
    private func configureVC() {
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        //setup layout
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
        
        //trigger fetch of photos
        performGetPhotos()
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
    

    private func performGetPhotos(forPage number: Int=1) {
        guard let pin = pin else { return }
        
        //show / start animating activity indicator
        collectionViewActivityIndicator(animate: true)
        
        VTNetworkController.shared.getPhotos(for: (lat: pin.latitude, lon: pin.longitude), page: number) { [weak self] result in
            guard let self = self else { return }
            
            //stop / hide animating activity indicator
            self.collectionViewActivityIndicator(animate: false)
            
            switch result {
            case .success(let photoCollection):
                print("Photos page: \(photoCollection.page) of \(photoCollection.pages)")
                self.displayPhotos(with: photoCollection)
                
                
            case .failure(let error):
                self.presentUserAlert(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
    
    
    internal func displayPhotos(with photoCollection: PhotoCollection) {
        self.photoCollection = photoCollection
        self.configureUI()
    }
}


//MARK: CollectionView Delegate
extension PhotoAlbumCollectionViewController: UICollectionViewDelegate {
    
    //support deleting item in collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        photoCollection.photos.remove(at: indexPath.item)
//        photoAlbumCollectionView.deleteItems(at: [indexPath])

        //display empty state
        if photos.isEmpty && photoCollection.pages < 2 {
            self.setEmptyStateView(true)
        }
    }
}


//MARK:- CollectionView Data Source

extension PhotoAlbumCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
//        return fetchedResultsController.sections?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
//        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //get photo object
        let photo = photos[indexPath.item]
        
        //configure cell
        let cell = photoAlbumCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell

        //set cell to default until photo image can be set
        cell.setPhotoImageViewToDefaultImage()
        
        //set cell image with actual photo
        switch photo.image {
        case nil:
            cell.performGetPhotoImage(from: photo.imageURL)

        default:
            if let data = photo.image {
                let image = UIImage(data: data)
                cell.setPhotoImageView(with: image) //if set image fails, pass in nil
            }
        }
        
        return cell
    }
}


//MARK:- Core Data
extension PhotoAlbumCollectionViewController: NSFetchedResultsControllerDelegate {
    
//    fileprivate func congifureFetchedResultsController() {
//        guard let pin = pin, let context = dataController?.viewContext else { return }
//
//        let fetchRequest:NSFetchRequest<PhotoCollection> = PhotoCollection.fetchRequest()
//        let predicate = NSPredicate(format: "pin == %@", pin)
//        fetchRequest.predicate = predicate
//
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        fetchRequest.sortDescriptors = [sortDescriptor]
//
//        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//        fetchedResultsController.delegate = self
//
//        do {
//            try fetchedResultsController.performFetch()
//        } catch {
//            fatalError("The fetch could not be performed: \(error.localizedDescription)")
//        }
//    }
}


// MARK:- Helpers
extension PhotoAlbumCollectionViewController {
    
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
        let pages = Int(photoCollection.pages)
        let currentPage = Int(photoCollection.page)
        
        let pageRange = 1...pages
        var randomPage = Int.random(in: pageRange)
        
        while randomPage == currentPage {
            randomPage = getRandomPage()
        }

        return Int(randomPage)
    }
    
    
    internal func convertNSSetPhotosToArray(photos: NSSet) -> [Photo]? {
        return photos.allObjects as? [Photo]
    }
}
