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
    
    
    func photoActivityIndicator(state isAnimating: Bool) {
        //unhide / hide viw
        isAnimating ? (photoActivityIndicator.isHidden = !isAnimating) : (photoActivityIndicator.isHidden = !isAnimating)
        
        //stop / start animation
        isAnimating ? photoActivityIndicator.startAnimating() : photoActivityIndicator.stopAnimating()
    }
    
    
    func performGetPhotoImage(from urlString: String) -> UIImage? {
        
        var cellImage = UIImage()
            
            VTNetworkController.shared.getPhotoImage(from: urlString) { (image) in
                
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
