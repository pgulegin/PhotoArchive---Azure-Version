//
//  CameraSelectedContextsAttributesTableViewCell.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class CameraSelectedContextsAttributesTableViewCell: UITableViewCell {
    
    // Cell attributes
    @IBOutlet weak var attributeTitle: UILabel!
    @IBOutlet weak var attributeDescription: UITextView!
    @IBOutlet weak var attributeAnswer: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
