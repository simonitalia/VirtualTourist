//
//  PhotoAlbumCollectionViewController+Extensions.swift
//  VirtualTourist
//
//  Created by Simon Italia on 6/15/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit
import CoreData

//MARK: - NSFetchedResultsControllerDelegate

extension PhotoAlbumCollectionViewController {
    
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
    
    
    @nonobjc func delete(object: NSManagedObject) {
        dataController?.viewContext.delete(object)
        try? dataController?.viewContext.save()
        dataController?.printCoreDataStatistics()
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
