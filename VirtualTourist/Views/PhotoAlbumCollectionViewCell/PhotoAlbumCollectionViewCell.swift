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
        photoImageView.image = image
    }
    
    
    private func photoActivityIndicator(animate: Bool) {
        
        DispatchQueue.main.async {
            //unhide / hide viw
            animate ? (self.photoActivityIndicator.isHidden = !animate) : (self.photoActivityIndicator.isHidden = !animate)
            
            //stop / start animation
            animate ? self.photoActivityIndicator.startAnimating() : self.photoActivityIndicator.stopAnimating()
        }
    }
    
    
    func performGetPhotoImage(from urlString: String) -> UIImage? {
        
        //start / show activity indicator
        photoActivityIndicator(animate: true)
        
        var cellImage = UIImage()
            
            VTNetworkController.shared.getPhotoImage(from: urlString) { [weak self] (image) in
                guard let self = self else { return }
                
                //stop / hide activity indicator
                self.photoActivityIndicator(animate: false)
                
                //set cellImage to downloaded image
                if let image = image {
                    cellImage = image

                //set cellImage to default image
                } else {
                    if let image = UIImage(named: "no-image-outline") {
                        cellImage = image
                    }
                }
            }
        
        return cellImage
    }
}
