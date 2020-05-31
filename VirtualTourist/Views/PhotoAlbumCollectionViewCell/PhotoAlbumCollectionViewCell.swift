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
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let image = UIImage(named: "camera") { //default image
            setPhotoImageView(with: image)
        }
    }
    
    
    //required init
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setPhotoImageView(with image: UIImage) {
        photoImageView.image = image
    }
    
    
    func photoActivityIndicator(state isAnimating: Bool) {
        //unhide / hide viw
        isAnimating ? (photoActivityIndicator.isHidden = !isAnimating) : (photoActivityIndicator.isHidden = !isAnimating)
        
        //stop / start animation
        isAnimating ? photoActivityIndicator.startAnimating() : photoActivityIndicator.stopAnimating()
    }
}
