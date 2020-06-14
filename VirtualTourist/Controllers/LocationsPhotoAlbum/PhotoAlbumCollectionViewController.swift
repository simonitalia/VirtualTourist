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
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyStateView: UIView!
    
    //actions
    @IBAction func newCollectionButtonTapped(_ sender: Any) {
        guard let pages = totalPages else { return }
        guard pages > 1 else {
            self.presentUserAlert(title: "No More Photos", message: "There are no other photos for this location.")
            return
        }
        
        //get random page
        let page = getRandomPage()
        performFetchPhotosFromSearch(forPage: Int(page))
    }
    
    
    //MARK:- Class Properties
    private let cellIdentifier = "PhotoCell"
    internal var currentPage: Int64? {
        return pin?.photoCollection?.page
    }
    
    internal var totalPages: Int64? {
        return pin?.photoCollection?.pages
    }
    
    private var pin: Pin? = {
        return PhotoAlbumMasterViewController.pin
    }()
    
    
    //MARK:- Data Persistence Properties
    //Core Data
    internal var dataController: DataController? {
        return DataController.shared
    }
    
    internal var fetchedResultsController: NSFetchedResultsController<Photo>?
    

    //MARK:- View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetchPhotos()
        configureVC()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {}
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if !emptyStateView.isHidden {
            self.setEmptyStateView(false)
        }
        
        fetchedResultsController = nil
    }
    
    
    //MARK:- ViewController Setup
    private func configureVC() {
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        //setup layout
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    

    internal func performFetchPhotos() {
        if let _ = pin?.photoCollection {
            performFetchPhotosFromCoreData()
            
        } else {
            performFetchPhotosFromSearch(forPage: 1)
        }
    }


    private func performFetchPhotosFromSearch(forPage number: Int) {
        guard let pin = pin else { return }
        
        print("\nFetching new photos for page \(number)....")
        
        //show / start animating activity indicator
        collectionViewActivityIndicator(animate: true)
        
        VTNetworkController.shared.getPhotos(for: pin, page: number) { [weak self] result in
            guard let self = self else { return }
            
            //stop / hide animating activity indicator
            self.collectionViewActivityIndicator(animate: false)
            
            switch result {
            case .success(let photoCollection):
                
                //update properties
                self.pin?.photoCollection = photoCollection
                self.performFetchPhotosFromCoreData()
                
            case .failure(let error):
                self.presentUserAlert(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
}


//MARK: CollectionView Delegate
extension PhotoAlbumCollectionViewController: UICollectionViewDelegate {
    
    //support deleting item in collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        guard let photo = fetchedResultsController?.object(at: indexPath) else { return }
        
        print("Objects BEFORE delete: \(fetchedResultsController?.fetchedObjects?.count ?? 0)")
        
        dataController?.viewContext.delete(photo)
        
        try? dataController?.viewContext.save()
        dataController?.printCoreDataStatistics()
        
        print("Objects AFTER delete: \(fetchedResultsController?.fetchedObjects?.count ?? 0)")
        
        if fetchedResultsController?.fetchedObjects == nil {
            self.setEmptyStateView(true)
        }
        
        //display empty state if objects afer delete
        if let count = fetchedResultsController?.fetchedObjects?.count, count < 1 {
            self.setEmptyStateView(true)
        }
    }
}


//MARK:- CollectionView Data Source

extension PhotoAlbumCollectionViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //configure cell
        let cell = photoAlbumCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell
        
        //remove any prior images in reused cell
        cell.setPhotoImageViewToDefaultImage()
        
        if let photo = self.fetchedResultsController?.fetchedObjects?[indexPath.item] {
            
            //set cell image with actual photo
            switch photo.image {
            case nil:
                cell.performGetPhotoImage(for: photo)

            default:
                if let data = photo.image {
                    let image = UIImage(data: data)
                    cell.setPhotoImageView(with: image) //if set image fails, pass in nil
                }
            }
        }
        
        return cell
    }
}


//MARK:- Core Data Delegate + Helpers
extension PhotoAlbumCollectionViewController: NSFetchedResultsControllerDelegate {
    
    private func performFetchPhotosFromCoreData() {
        guard let pin = pin, let context = dataController?.viewContext else { return }

        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "photoCollection.pin == %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            print("Fetched objects: \(fetchedResultsController?.fetchedObjects?.count ?? 0)")
            print("Fetched page \(currentPage ?? 0) of \(totalPages ?? 0) pages from core data.")

            //update UI
            updateUI()
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            photoAlbumCollectionView.insertItems(at: [newIndexPath!])
            break
        
        case .delete:
            photoAlbumCollectionView.deleteItems(at: [indexPath!])
            break
        
        case .update:
            photoAlbumCollectionView.reloadItems(at: [indexPath!])
        
        case .move:
            photoAlbumCollectionView.moveItem(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Invalid change type in controller(_:didChange:anObject:for:).")
        }
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert: photoAlbumCollectionView.insertSections(indexSet)
        case .delete: photoAlbumCollectionView.deleteSections(indexSet)
        case .update: photoAlbumCollectionView.reloadSections(indexSet)
            
        case .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:)")
        
        @unknown default:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:)")
        }
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         
    }
}


// MARK:- CollectionView UI Helpers
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
    
    
    private func updateUI() {
         DispatchQueue.main.async {
            guard let photos = self.fetchedResultsController?.fetchedObjects, !photos.isEmpty else {
                self.setEmptyStateView(true)
                return
            }

            self.photoAlbumCollectionView.reloadData()
        }
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
            self.newCollectionButton.isEnabled = !display
        }
    }
}


//MARK:- Helpers
extension PhotoAlbumCollectionViewController {
    
    private func getRandomPage() -> Int64 {
        guard let totalPages = totalPages else { return 0 }
        
        let pageRange = 1...totalPages
        var randomPage = Int64.random(in: pageRange)
        
        while randomPage == currentPage {
            randomPage = getRandomPage()
        }

        return randomPage
    }
}
