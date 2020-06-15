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
    
    //MARK: - Storyboard Connections
    
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
        
        let page = getRandomPage()
        performFetchPhotosFromSearch(forPage: Int(page))
    }
    
    
    //MARK: - Class Properties
    
    enum CollectionViewSection {
        case main
    }
    
    
    //collection view properties
    let cellIdentifier = "PhotoCell"
    var collectionViewDataSource: UICollectionViewDiffableDataSource<CollectionViewSection, Photo>?
    
    
    private var currentSearchTask: URLSessionDataTask?
    private var currentPage: Int64? {
        return pin?.photoCollection?.page
    }
    
    private var totalPages: Int64? {
        return pin?.photoCollection?.pages
    }
    
    private var pin: Pin? = {
        return PhotoAlbumMasterViewController.pin
    }()
    
    
    //MARK: - Data Persistence Properties
    
    //Core Data
    var dataController: DataController? {
        return DataController.shared
    }
    
    var fetchedResultsController: NSFetchedResultsController<Photo>?
    

    //MARK: - View Lifecycle
    
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
        cancelDataTasks()
    }
    
    
    //MARK: - ViewController Setup
    
    private func configureVC() {
        configureCollectionView()
    }
    
    
    private func configureCollectionView() {
        
        //setup layout and cell
        configureCollectionViewCell()
        
        let layout = configureCompositionalLayout()
        photoAlbumCollectionView.setCollectionViewLayout(layout, animated: false)
    }
    

    //called on view load
    private func performFetchPhotos() {
        if let pin = pin, let _ = pin.photoCollection {
            performFetchPhotosFromCoreData(for: pin)
            
        } else {
            performFetchPhotosFromSearch(forPage: 1)
        }
    }


    private func performFetchPhotosFromSearch(forPage number: Int) {
        guard let pin = pin else { return }
        
        //cancel any existing running tasks
        cancelDataTasks()
        
        print("\nFetching new photos for page \(number)....")
        
        //show / start animating activity indicator
        collectionViewActivityIndicator(animate: true)
        collectionViewSetUserInput(enabled: false)
        
        currentSearchTask = VTNetworkController.shared.getPhotos(for: pin, page: number) { [weak self] result in
            guard let self = self else { return }
            
            //stop / hide animating activity indicator
            self.collectionViewActivityIndicator(animate: false)
            self.collectionViewSetUserInput(enabled: true)
            
            switch result {
            case .success(let pin):
                self.pin = pin
                self.performFetchPhotosFromCoreData(for: pin)
                
            case .failure(let error):
                self.presentUserAlert(title: "Something went wrong", message: error.rawValue)
            }
        }
    }
}


//MARK: - Core Data Helpers

extension PhotoAlbumCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func performFetchPhotosFromCoreData(for pin: Pin) {
        guard let identifier = pin.identifier else { return }
        guard let context = dataController?.viewContext else { return }

        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "photoCollection.pin.identifier == %@", identifier)
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self

        do {
            try fetchedResultsController?.performFetch()
            print("Fetched objects: \(fetchedResultsController?.fetchedObjects?.count ?? 0)")
            print("Fetched page \(currentPage ?? 0) of \(totalPages ?? 0) pages from core data.")

            //update Collection View Data Source
            updateCollectionViewSnapshot()
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    
    
    
    func performDelete() {
        guard let photos = fetchedResultsController?.fetchedObjects, !photos.isEmpty else { return }
        guard let context = dataController?.backgroundContext else {
            print("Error! Delete of Photos di not initiate")
            return
        }
        
        do {
            try Photo.delete(photos: photos, in: context)
            dataController?.printCoreDataStatistics()
            
        } catch {
            print("Error! Error encountered deleting photos. \(error.localizedDescription)")
        }
    }
}


// MARK:- UI Helpers

extension PhotoAlbumCollectionViewController {
    
    func updateUI() {
         DispatchQueue.main.async {
            if let count = self.fetchedResultsController?.fetchedObjects?.count, count < 1 {
                self.setEmptyStateView(true)
            }
        }
    }


    //set view UI elements state
    private func collectionViewActivityIndicator(animate: Bool) {
        
        DispatchQueue.main.async {
            self.collectionViewActivityIndicator.isHidden = !animate
            animate ? self.collectionViewActivityIndicator.startAnimating() : self.collectionViewActivityIndicator.stopAnimating()
        }
    }
    
    
    private func setEmptyStateView(_ display: Bool) {
        DispatchQueue.main.async {
            self.photoAlbumCollectionView.isHidden = display
            self.view.bringSubviewToFront(self.emptyStateView)
            self.emptyStateView.isHidden = !display
        }
    }
    
    
    private func collectionViewSetUserInput(enabled: Bool) {
        DispatchQueue.main.async {
            self.photoAlbumCollectionView.isUserInteractionEnabled = enabled
            self.newCollectionButton.isEnabled = enabled
        }
    }
}


//MARK: - Helpers

extension PhotoAlbumCollectionViewController {
    
    private func cancelDataTasks() {
        currentSearchTask?.cancel()
        PhotoAlbumCollectionViewCell.fetchPhotoTasks?.forEach { $0.cancel() }
    }
    
    
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
