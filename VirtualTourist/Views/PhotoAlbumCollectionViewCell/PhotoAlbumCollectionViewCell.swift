//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Simon Italia on 5/31/20.
//  Copyright © 2020 SDI Group Inc. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Storyboard Connections
    //outlets
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoActivityIndicator: UIActivityIndicatorView!
    

    func setPhotoImageView(with image: UIImage) {
        DispatchQueue.main.async {
            self.photoImageView.image = image
            self.setNeedsDisplay()
        }
    }
    
    
    private func photoActivityIndicator(animate: Bool) {
        
        DispatchQueue.main.async {
            self.photoActivityIndicator.isHidden = !animate
            animate ? self.photoActivityIndicator.startAnimating() : self.photoActivityIndicator.stopAnimating()
        }
    }
    
    
    func performGetPhotoImage(from urlString: String) {
        
        //start / show activity indicator
        photoActivityIndicator(animate: true)
        
        VTNetworkController.shared.getPhotoImage(from: urlString) { [weak self] (image) in
            guard let self = self else { return }
            
            //stop / hide activity indicator
            self.photoActivityIndicator(animate: false)
            
            //set cellImage to downloaded image
            if let image = image {
                self.setPhotoImageView(with: image)

            //set cellImage to default image if no image for photo object
            } else {
                if let image = UIImage(named: "no-image-outline") {
                    self.setPhotoImageView(with: image)
                }
            }
        }
    }
}
