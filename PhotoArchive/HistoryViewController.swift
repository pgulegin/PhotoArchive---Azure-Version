//
//  HistoryViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 1/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit
import Kingfisher

class HistoryViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var historyCollectionView: UICollectionView! // Collection of the history images
    var imageTitles = [String]()                                // Title for the image
    var imagePaths = [String]()                                 // String for the path of the image
    var thumbnailPaths = [String]()                             // String for the page of the thumbnail
    
    var imageForSeque: String?      // String item for the image to prepare for transition
    var titleForSeque: String?      // String item for the title to preapre for transition
    
    var blobClient: AZSCloudBlobClient = AZSCloudBlobClient()           // Blob storage for the image
    var blobContainer: AZSCloudBlobContainer = AZSCloudBlobContainer()  // Blob container for the image
    
    var imageTable: MSTable?                                            // Table for all of the images
    
    let userID = UserDefaults.standard.string(forKey: UD.username)!     // User identification to load appropraite images
    
    // SAS key for the database
    let sas = "sv=2016-05-31&ss=b&srt=o&sp=rw&se=2027-02-24T00:00:00Z&st=2017-02-24T00:00:00Z&spr=https&sig=kChTx0B8faa43g%2F%2F2G5LIWBCOKMxq1eIgqOUn9Ds9s4%3D"
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Account connection
        let account = try! AZSCloudStorageAccount(fromConnectionString: "SharedAccessSignature=" + sas + ";BlobEndpoint=https://boephotostore.blob.core.windows.net")
        
        // Establishing the blob for the account
        blobClient = account.getBlobClient()
        
        // Establishing the container from the blob
        blobContainer = blobClient.containerReference(
            fromName:"photocontainer"
        )
        
        // Main application delegate for conection
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        // Client call for Azure
        let client = delegate.client!
        
        // Loads image table
        imageTable = client.table(withName: "Image");
        
        // Loads all images
        loadImages();
    }
    
    // Loads all of the images from the image table
    func loadImages(){
        
        // Creates a query for images
        let imgQuery = imageTable!.query()
        
        // Searches for images uploaded by the current user
        imgQuery.predicate = NSPredicate(format: "userID == %@", userID)
        
        // Reads the images from databse
        imgQuery.read(completion: {
            (result, error) in
            if let err = error {
                print("Error ", err);
            } else if let imgResults = result?.items {
                for img in imgResults {
                    
                    // Creates a new path for all of the images
                    let path = img["id"] as! String
                    
                    // If the path is not already in the list,
                    if(!self.imageTitles.contains(path)){
                        
                        // Add path to titles list
                        self.imageTitles.insert(path, at: 0)
                        
                        // Creates the image path -- image names are changed when uploaded to the database
                        var imagePath = path.replacingOccurrences(
                            of: "_",
                            with: "/",
                            options: NSString.CompareOptions.literal,
                            range: path.range(of: "_")
                        )
                        
                        // Modifies the image path
                        imagePath = self.blobContainer.storageUri.primaryUri.absoluteString
                            + "/"
                            + imagePath
                            + "?"
                            + self.sas;
                        
                        // Creates the thumbnail path -- thumbnail names are changed when uploaded to the database
                        var thumbnailPath = path.replacingOccurrences(
                            of: "_",
                            with: "/thumbnails/",
                            options: NSString.CompareOptions.literal,
                            range: path.range(of: "_")
                        )
                        
                        // Modifies the thumbnail path
                        thumbnailPath = self.blobContainer.storageUri.primaryUri.absoluteString
                            + "/"
                            + thumbnailPath
                            + "?"
                            + self.sas;
                        
                        // Inserts the image and thumbnail into the globsl arrays
                        self.imagePaths.insert(imagePath, at: 0)
                        self.thumbnailPaths.insert(thumbnailPath, at: 0)
                    }
                    
                    // Reloads the collection view
                    self.historyCollectionView.reloadData()
                }
            }
        })
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Notifies the view controller that its view is about to be removed from a view hierarchy
    override func viewWillDisappear(_ animated: Bool) {
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    // Notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Loads all of the images
        loadImages()
        
        // Changes the background color to the current theme
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }
    
    // Asks your data source object for the number of items in the specified section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagePaths.count
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Creates the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "historyCell", for: indexPath) as! HistoryCollectionViewCell
        
        // Prevent user interaction while loading
        cell.isUserInteractionEnabled = false;
        
        // Load thumbnails
        let url = URL(string: self.thumbnailPaths[indexPath.row]);
        
        // Activity indicator to let the user know the cell is being loaded
        cell.imageView?.kf.indicatorType = .activity
        
        // Loads the image
        let image = ImageCache.default.retrieveImageInDiskCache(forKey: url!.absoluteString);
        
        // Sets the completion handler for the cell
        if(image == nil){
            cell.imageView?.kf.setImage(with: url, options: [.transition(.fade(0.2)),.forceRefresh],completionHandler: {
                (image, error, cacheType, imageUrl) in
                if(image != nil){
                    cell.isUserInteractionEnabled = true;
                }
            });
        }
        // Displays the image
        else{
            cell.imageView.image = image;
            cell.isUserInteractionEnabled = true;
        }
        
        // Returns the cell
        return cell
    }
    
    // Tells the delegate that the item at the specified index path was selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Prepares to send the image to the next view controller
        self.imageForSeque = self.imagePaths[indexPath.row]
        
        // Prepates to send the title to the next view controller
        self.titleForSeque = self.imageTitles[indexPath.row]
        
        // Performs the segue to the next view controller
        self.performSegue(withIdentifier: "historyShowImageSegue", sender: self)
    }
    
    // Notifies the view controller that a segue is about to be performed
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Checks for the appropriate view controller for segue
        if segue.identifier == "historyShowImageSegue" {
            
            // Creates the next view controller
            let vc = segue.destination as! HistoryImageViewController
            
            // Sends the image path and the title to the next view controller
            vc.imagePath = self.imageForSeque!
            vc.title = self.titleForSeque!
        }
    }
}
