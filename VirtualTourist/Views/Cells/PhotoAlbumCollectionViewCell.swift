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
//                self.setNeedsDisplay()
                self.setNeedsLayout()
            }
        }
    }
    

    func setPhotoImageView(with image: UIImage?) {
        
        DispatchQueue.main.async {
            if let image = image {
                self.photoImageView.image = image
//                self.setNeedsDisplay()
                self.setNeedsLayout()
            
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
    
    
    func performGetPhotoImage(for photo: Photo) {
        guard let _ = photo.imageURL else { return }
           
       //start / show activity indicator
       photoActivityIndicator(animate: true)
       
       VTNetworkController.shared.getPhotoImage(for: photo) { [weak self] (result) in
           guard let self = self else { return }
           
           //stop / hide activity indicator
           self.photoActivityIndicator(animate: false)
        
            switch result {
            case .success(let image):
                self.setPhotoImageView(with: image)
            
            case .failure(let error):
                print(error.rawValue)
            }
        }
    }
}
