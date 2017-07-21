//
//  TaggingTagCollectionViewCell.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 2/14/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingTagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    var contextName: String! {
        didSet {
            title.text = contextName
        }
    }
}
