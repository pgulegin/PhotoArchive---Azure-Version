//
//  TaggingGalleryOverviewCollectionViewCell.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/23/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingGalleryOverviewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    var cellSelected = false
}
