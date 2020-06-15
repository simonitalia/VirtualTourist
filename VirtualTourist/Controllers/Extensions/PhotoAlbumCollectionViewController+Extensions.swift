//
//  PhotoAlbumCollectionViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/15/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData


//MARK: - CollectionView Data Source + Data Helpers

extension PhotoAlbumCollectionViewController {
    
    func configureCollectionViewCell() {
        collectionViewDataSource = UICollectionViewDiffableDataSource<CollectionViewSection, Photo>(collectionView: photoAlbumCollectionView) { [unowned self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            
           //configure cell
            let cell = self.photoAlbumCollectionView.dequeueReusableCell(withReuseIdentifier: self.cellIdentifier, for: indexPath) as! PhotoAlbumCollectionViewCell

            if let photo = self.fetchedResultsController?.fetchedObjects?[indexPath.item] {
                
                //set cell image with actual photo
                switch photo.image {
                case nil:
                    cell.imageURL = photo.imageURL //capture url of image request to avodin mismatch of recycled cells and images
                    cell.setPhotoImageToDownloading()
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
    
    
    func updateCollectionViewSnapshot() {
        
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, Photo>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.fetchedResultsController?.fetchedObjects ?? [])
            self.collectionViewDataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
        }
        
        //update UI
        updateUI()
    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCollectionViewSnapshot()
    }
    
    
    @nonobjc func delete(object: NSManagedObject) {
        dataController?.viewContext.delete(object)
        try? dataController?.viewContext.save()
        dataController?.printCoreDataStatistics()
    }
}


//MARK: CollectionView Delegate

extension PhotoAlbumCollectionViewController: UICollectionViewDelegate {
    
    //support deleting item in collection
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        guard let photo = fetchedResultsController?.object(at: indexPath) else { return }

        delete(object: photo)
        try? dataController?.viewContext.save()
        dataController?.printCoreDataStatistics()
        
        //display empty state if objects afer delete
        updateUI()
    }
}
    
    
//MARK: - CollectionView Layout

extension PhotoAlbumCollectionViewController {

    func configureCompositionalLayout() -> UICollectionViewLayout {
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
