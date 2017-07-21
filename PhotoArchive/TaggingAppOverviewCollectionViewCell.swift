//
//  TaggingAppOverviewCollectionViewCell.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingAppOverviewCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    var representedAssetIdentifier: String!
    var thumbnailImage: UIImage! {
        didSet {
            imageView.image = thumbnailImage
        }
    }
    var cellSelected = false
}
