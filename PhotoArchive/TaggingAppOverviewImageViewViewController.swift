//
//  TaggingAppOverviewImageViewViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingAppOverviewImageViewViewController: UIViewController {
    
    // Displays the object in the view controller
    @IBOutlet weak var imageView: UIImageView!
    
    // Object which is passed in from the Dashboard
    var cameraObject: CameraObject!
    
    /**
     Deletes the current object which is being displayed.
     
     - Parameter sender: Trigger by when the user pressed the delete button
     */
    @IBAction func deleteAction(_ sender: Any) {
        
        // Establish all of the camera obects
        var cameraObjects = [CameraObject]()
        
        // Loads 'UploadObjects' from persistent memory
        if (PersistenceManager.loadNSArray(.CameraObjects) as? [CameraObject]) != nil {
            
            // Passes in all upload objects from memory
            cameraObjects = PersistenceManager.loadNSArray(.CameraObjects) as! [CameraObject]
        }
        
        // Cycles through every upload object
        for i in 0..<cameraObjects.count {
            
            // Executes when the correct upload object is found
            if cameraObject.imageName == cameraObjects[i].imageName {
                
                // Removes specific upload object
                cameraObjects.remove(at: i)
                
                // Breaks out of the for loop
                break
            }
        }
        
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Gets the location of image from the appropriate 'UploaObject'
        let fullImageURL = docURL.appendingPathComponent(cameraObject.imageLocation)
        
        // Gets the location of thumbnail from the appropriate 'UploaObject'
        let thumbnailURL = docURL.appendingPathComponent(cameraObject.thumbnailLocation)
        
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
        
        // Saves the UploadObjects to memory
        PersistenceManager.saveNSArray(cameraObjects as NSArray, path: .CameraObjects)
        
        // Takes user back to the App Overview Collection
        performSegue(withIdentifier: "unwindToTaggingAppOverviewCollectionView", sender: self)
    }
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        
        // Makes sure the view loads
        super.viewDidLoad()
        
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Gets the location of the image from the appropriate 'UploaObject'
        let fullImageURL = docURL.appendingPathComponent(cameraObject.imageLocation)
        
        // Sets the image to be displayed
        self.imageView.image = UIImage(contentsOfFile: fullImageURL.path)!
    }
    
    // Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
