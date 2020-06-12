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
    
    
    func setPhotoImageViewToDefaultImage() {
        DispatchQueue.main.async {
            if let image = UIImage(named: "camera-outline") {
                self.photoImageView.image = image
                self.setNeedsDisplay()
            }
        }
    }
    

    func setPhotoImageView(with image: UIImage?) {
        
        DispatchQueue.main.async {
            if let image = image {
                self.photoImageView.image = image
                self.setNeedsDisplay()
            
            } else {
                self.setPhotoImageViewToDefaultImage()
            }
        }
    }
    
    
    private func photoActivityIndicator(animate: Bool) {
        
        DispatchQueue.main.async {
            self.photoActivityIndicator.isHidden = !animate
            animate ? self.photoActivityIndicator.startAnimating() : self.photoActivityIndicator.stopAnimating()
        }
    }
    
    
    func performGetPhotoImage(from urlString: String?) {
        guard let urlString = urlString else {
            setPhotoImageViewToDefaultImage()
            return
        }
        
        //start / show activity indicator
        photoActivityIndicator(animate: true)
        
        VTNetworkController.shared.getPhotoImage(from: urlString) { [weak self] (image) in
            guard let self = self else { return }
            
            //stop / hide activity indicator
            self.photoActivityIndicator(animate: false)
            
            //pass downloaded image (or nil)
            self.setPhotoImageView(with: image)
        }
    }
}
