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
            
            //remove any prior images in reused cell
            cell.setPhotoImageToDownloading()
            
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
    
    
    func updateCollectionViewSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<CollectionViewSection, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(fetchedResultsController?.fetchedObjects ?? [])
        self.collectionViewDataSource?.apply(snapshot, animatingDifferences: true, completion: nil)
        
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
