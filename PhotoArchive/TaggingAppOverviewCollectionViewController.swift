//
//  TaggingAppOverviewCollectionViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "TaggingAppOverviewCollectionViewCell"

class TaggingAppOverviewCollectionViewController: UICollectionViewController {
    
    // The main outlets in this view controller
    @IBOutlet weak var titleCounter: UINavigationItem!      // When selecting mode is on, displays the number of items selected
    @IBOutlet var deselectButtonOutlet: UIBarButtonItem!    // When selecting mode is on, displays deselection of all items button
    @IBOutlet var selectButtonOutlet: UIBarButtonItem!      // Allows user to select items
    
    // Selection mode tracker
    var selecting = false
    
    // Default size for thumbnails for the view cells
    let thumbnailSize = CGSize(width: 80, height: 80)
    
    // Holds all of the camera objects
    var cameraObjects = [CameraObject]()
    
    // Allows the user to enter/exit selecting mode
    @IBAction func selectButton(_ sender: Any) {
        
        // Executes if selecting is currently on, but user wants it off
        if selecting {
            
            // Sets selecting mode to off
            selecting = false
        }
        // Executes if selecting is currently off, but user wants it on
        else {
            
            // Sets selecting mode to on
            selecting = true
        }
        
        reloadNavigationBar()
    }
    
    // Only visible when selecting mode is on; allows user to deselect all items
    @IBAction func deselectAllButton(_ sender: Any) {
        
        // Deselect all items currently selected
        global.shared.appImages.removeAll()
        
        // Refresh the navigation bar
        reloadNavigationBar()
        
        // Reload all of the items which are currently visible
        collectionView?.reloadItems(at: (collectionView?.indexPathsForVisibleItems)!)
    }

    // Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()

        // Refresh the navigation bar
        reloadNavigationBar()
        
        // Checks to see if 'CameraObject' array exists in memory
        if (PersistenceManager.loadNSArray(.CameraObjects) as? [CameraObject]) != nil {
            
            // Loads 'CameraObject' array
            cameraObjects = PersistenceManager.loadNSArray(.CameraObjects) as! [CameraObject]
        }
        
        // Only executes deletion of images if the user has auto delete turned on
        if UserDefaults.standard.object(forKey: UD.isAutoImageExpires) as! Bool {
            
            // Deletes elements which have expired
            for object in cameraObjects {
                
                // Creates a format for a date
                let dateFormatter = DateFormatter()
                
                // Adapts to the format in the string -- this is the string used for the file names
                dateFormatter.dateFormat = "y-MM-dd-H-m-ss-SSSS"
                
                // Gets the date from the file name of the current object
                let date = dateFormatter.date(from: object.imageName)!
                
                // Gets how many days until image expires from user settings -- based on the Settings page
                let timeInterval = UserDefaults.standard.object(forKey: UD.imageExpiresIn) as! Int
                
                // Figures out the when image should expire
                let expireDate = date.addingTimeInterval(TimeInterval(60 * 60 * 24 * timeInterval))
                
                // Executes if the expiration date has passed
                if Date() > expireDate {
                    
                    // Removes the current object from the 'cameraObjects' array
                    cameraObjects.remove(at: cameraObjects.index(of: object)!)
                    
                    // Establish FileManager object
                    let fileMngr = FileManager.default
                    
                    // Establish path to 'Documents'
                    let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    
                    // Gets the location of image from the appropriate 'UploaObject'
                    let fullImageURL = docURL.appendingPathComponent(object.imageLocation)
                    
                    // Gets the location of thumbnail from the appropriate 'UploaObject'
                    let thumbnailURL = docURL.appendingPathComponent(object.thumbnailLocation)
                    
                    // Deletes image from filesystem
                    do {
                        try fileMngr.removeItem(at: fullImageURL)
                    } catch {
                        print("There was an error  deleting this file.")
                    }
                    
                    // Deletes thumbnail from filesystem
                    do {
                        try fileMngr.removeItem(at: thumbnailURL)
                    } catch {
                        print("There was an error  deleting this file.")
                    }
                }
            }
        }
        
        // Saves the UploadObjects to memory
        PersistenceManager.saveNSArray(cameraObjects as NSArray, path: .CameraObjects)
    }

    // Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reloads all items which should be in the collection view
        if (PersistenceManager.loadNSArray(.CameraObjects) as? [CameraObject]) != nil {
            
            // Loads 'CameraObject' array
            cameraObjects = PersistenceManager.loadNSArray(.CameraObjects) as! [CameraObject]
        }
        
        // Reload entire collection view
        collectionView!.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Gets the next view controller
        let nextViewController = segue.destination as! TaggingAppOverviewImageViewViewController
        
        // Gets the indexPath of the selected cell
        let indexPath = collectionView!.indexPathsForSelectedItems![0]
        
        // Passes in the obect to be displayed
        nextViewController.cameraObject = cameraObjects[indexPath.row]
    }
    
    // Prepares for a segue transition from the Attribute pages
    @IBAction func unwindToTaggingAppOverviewCollectionView(segue:UIStoryboardSegue) {}
    

    // MARK: - Collection View

    // Asks your data source object for the number of sections in the collection view
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        // There will only be 1 section in this collection view
        return 1
    }

    // Asks your data source object for the number of items in the specified section.
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Returns the total number of cells to display
        return cameraObjects.count
    }

    // Asks your data source object for the cell that corresponds to the specified item in the collection view
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Cell which will be configured and displayed
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TaggingAppOverviewCollectionViewCell
    
        // The current object which will be displayed by this cell
        let object = cameraObjects[indexPath.row]
        
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]

        // URL to the location of the thumbnail
        let thumbnailURL = docURL.appendingPathComponent(object.thumbnailLocation)
        
        // Sets cell to display image
        cell.imageView.image = UIImage(contentsOfFile: thumbnailURL.path)!

        // Executes if cell has already been selected
        if global.shared.appImages.contains(object) {
            cell.layer.borderWidth = 3
            cell.layer.borderColor = ThemeManager.applyCellOutline(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as! Int)
        }
        // Executes if cell has not yet been selected
        else {
            cell.layer.borderWidth = 0
        }
    
        // Returns configured cell
        return cell
    }
    
    // Tells the delegate that the item at the specified index path was selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Executes if selecting mode is on
        if selecting {
            
            // Establishes the object which was just selected
            let object = cameraObjects[indexPath.row]
            
            // Executes if cell has not yet been selected
            if !global.shared.appImages.contains(object) {
                
                // Selects the cell
                global.shared.appImages.append(object)
            }
            // Executes if cell has already been selected
            else {
                
                // Removes the cell from selection
                global.shared.appImages.remove(at: global.shared.appImages.index(of: object)!)
            }
            
            // Refresh the navigation bar
            reloadNavigationBar()
            
            // Reload colleciton view at the current cell
            collectionView.reloadItems(at: [indexPath])
        }
        // Executes if selecting mode is off
        else {
            
            // Performs a segue to view the image in full screen
            performSegue(withIdentifier: "TaggingAppOverviewImageViewSegue", sender: self)
        }
    }
    
    // MARK: - User Functions
    
    /**
        Reloads the navigation bar. Should only be called when an item is selected or when user is switching between selecting modes.
    */
    func reloadNavigationBar() {
        
        // Executes if selecting mode is on
        if selecting {
            
            // Clears the navigation bar
            navigationItem.rightBarButtonItems?.removeAll()
            
            // Adds selection button
            navigationItem.rightBarButtonItems?.append(selectButtonOutlet)
            
            // Adds deslection button
            navigationItem.rightBarButtonItems?.append(deselectButtonOutlet)
            
            // Updates title with total number of items selected
            titleCounter.title = "\(global.shared.appImages.count) selected"
            
            // Allows collection view to select multiple items
            collectionView?.allowsMultipleSelection = true
        }
            // Executes if selection mode is off
        else {
            
            // Clears navigation bar
            navigationItem.rightBarButtonItems?.removeAll()
            
            // Adds selection button
            navigationItem.rightBarButtonItems?.append(selectButtonOutlet)
            
            // Clears out title
            titleCounter.title = ""
            
            // Disallows collection view to selection multiple items
            collectionView?.allowsMultipleSelection = false
        }
    }
}
