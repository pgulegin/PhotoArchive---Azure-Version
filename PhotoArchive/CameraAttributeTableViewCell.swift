//
//  CameraAttributeTableViewCell.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/25/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class CameraAttributeTableViewCell: UITableViewCell {
    
    // Attributes for the cell
    @IBOutlet weak var attributeTitle: UILabel!
    @IBOutlet weak var attributeDescription: UITextView!
    @IBOutlet weak var attributeAnswer: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Bold the font to identify which attribute is being manipulated
        attributeTitle.font = UIFont.boldSystemFont(ofSize: 17)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
