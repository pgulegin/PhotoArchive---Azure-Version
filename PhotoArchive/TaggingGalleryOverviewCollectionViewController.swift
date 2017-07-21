//
//  TaggingGalleryOverviewCollectionViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/23/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class TaggingGalleryOverviewCollectionViewController: UICollectionViewController {
    
    // Manages interface on the application
    @IBOutlet weak var titleCount: UINavigationItem!        // Title at the top
    @IBOutlet var deselectButtonOutlet: UIBarButtonItem!    // Deselection button for cells
    @IBOutlet var selectButtonOutlet: UIBarButtonItem!      // Selection button for cells
    var sharing = false                                     // Tracks whether application is being selected/deselected
    
    // Fetches images from iPhotos
    var fetchResult: PHFetchResult<PHAsset>!                // Fetches images from iPhotos
    var assetCollection: PHAssetCollection!                 // Collects all of the images together
    fileprivate let imageManager = PHCachingImageManager()  // Grabs the images from iPhotos
    fileprivate var thumbnailSize: CGSize!                  // Sets an appropriate size for the thumbnails

    // Selects and remembers selected images
    var selectedAsset: PHAsset!                             // Currently selected asset
    var selectedAssetCollection: PHAssetCollection!         // Collection of assets which have been selected
    
    // Action which allows for the selection of images
    @IBAction func selectButton(_ sender: Any) {
        
        // Chceks if sharing is being turned on or off first
        if sharing {
            sharing = false
        }
        else {
            sharing = true
        }
        
        // If sharing was just turned on
        if sharing {
            
            // Clear out the right navigation bar
            navigationItem.rightBarButtonItems?.removeAll()
            
            // Add in 'select' button
            navigationItem.rightBarButtonItems?.append(selectButtonOutlet)
            
            // And 'deselect' button
            navigationItem.rightBarButtonItems?.append(deselectButtonOutlet)
            
            // Updates the title
            titleCount.title = "\(global.shared.galleryImages.count) selected"
            
            // Allows selection of multiple items
            collectionView?.allowsMultipleSelection = true
        }
        // If sharing was just turned off
        else {
            
            // Clears out the right navigation bar
            navigationItem.rightBarButtonItems?.removeAll()
            
            // Add in 'select' button
            navigationItem.rightBarButtonItems?.append(selectButtonOutlet)
            
            // Set title to be empty, because we are not currently selecting anything
            titleCount.title = ""
            
            // Disallows selection of mulitple items
            collectionView?.allowsMultipleSelection = false
        }
        
    }
    
    // Actino which allows user to deselect all items
    @IBAction func deselectAllButton(_ sender: Any) {
        
        // Removes all selected images
        global.shared.galleryImages.removeAll()
        
        // Updates title to reflect changes
        titleCount.title = "\(global.shared.galleryImages.count) selected"
        
        // Reloads all data from the collection view
        collectionView?.reloadData()
    }
    
    // Executes when view controller loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        let cellSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        thumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
        
        // Fetches images from iPhotos
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)

        // Clears out the right navigation bar
        navigationItem.rightBarButtonItems?.removeAll()
        
        // Add in 'select' button
        navigationItem.rightBarButtonItems?.append(selectButtonOutlet)
        
        // Sets title to empty because images are not currently being selected
        titleCount.title = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Sets the destination to the next view controller
        let destination = segue.destination as? TaggingGalleryOverviewImageViewViewController
        
        // Passes the selected asset to the next view controller
        let indexPaths = collectionView?.indexPathsForSelectedItems
        let indexPath = indexPaths?[0]
        destination?.asset = fetchResult.object(at: (indexPath?.item)!)
        destination?.assetCollection = assetCollection
    }

    // MARK: UICollectionViewDataSource

    // Returns number of sections in the collection view
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    // Returns numbers of items in a specific collection section
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return fetchResult.count
    }

    // Prepares a cell for the collection
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Fetches an object at a specified location
        let asset = fetchResult.object(at: indexPath.item)
        
        // Initializes the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TaggingGalleryOverviewCollectionViewCell", for: indexPath) as! TaggingGalleryOverviewCollectionViewCell
    
        // Configure the cell
    
        // Request an image for the asset from the PHCachingImageManager.
        cell.representedAssetIdentifier = asset.localIdentifier
        imageManager.requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: nil, resultHandler: { image, _ in
            // The cell may have been recycled by the time this handler gets called;
            // set the cell's thumbnail image only if it's still showing the same asset
            if cell.representedAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = image
            }
        })
        
        // Outlines the cell if it has been selected
        if global.shared.galleryImages.contains(asset) {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = ThemeManager.applyCellOutline(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
        }
        // Makes sure the cell is not outlined if it is not selected
        else {
            cell.layer.borderWidth = 0
        }
        
        // Returns the now prepared cell
        return cell
    }
    
    // Executes when an item is selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Executes if sharing is currently turned on
        if sharing {
            
            // Grabs the selected asset
            let asset = fetchResult.object(at: indexPath.row)
            
            // Executes if global does not contain the asset
            if !global.shared.galleryImages.contains(asset) {
                global.shared.galleryImages.append(asset)
            }
            // Executes if global does contain the asset
            else {
                // Item is removed from global
                global.shared.galleryImages.remove(at: global.shared.galleryImages.index(of: asset)!)
            }
            
            // Updates the title at the top
            titleCount.title = "\(global.shared.galleryImages.count) selected"
            
            // Reloads only the sected item
            collectionView.reloadItems(at: [indexPath])
        }
        else {
            // Moves to the next view controller
            performSegue(withIdentifier: "TaggingGalleryOverviewImageViewSegue", sender: self)
        }
    }
}
