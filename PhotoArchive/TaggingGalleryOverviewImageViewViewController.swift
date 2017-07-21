//
//  TaggingGalleryOverviewImageViewViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/23/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class TaggingGalleryOverviewImageViewViewController: UIViewController {
    
    var asset: PHAsset!
    var assetCollection: PHAssetCollection!

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the options for fetching images
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = true
        options.progressHandler = { progress, _, _, _ in
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        // Request a specified image to display
        PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
            // Hide the progress view now the request has completed
            self.progressView.isHidden = true
            
            // If successful, show the image view and display the image
            guard let image = image else { return }
            
            // Now that we have the image, show it.
            self.imageView.isHidden = false
            self.imageView.image = image
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Gets the size for the image
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }
    
    // Executes once the view appears
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Applies the appropriate color to the background
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }
}
