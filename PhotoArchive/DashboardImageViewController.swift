//
//  DashboardImageViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 2/1/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class DashboardImageViewController: UIViewController {

    // Displays the object in the view controller
    @IBOutlet weak var imageView: UIImageView!
    
    // Object which is passed in from the Dashboard
    var uploadObject: UploadObject!
    
    /**
        Deletes the current object which is being displayed.
     
        - Parameter sender: Trigger by when the user pressed the delete button
    */
    @IBAction func deleteAction(_ sender: Any) {
        
        // Establish all of the upload obects
        var uploadObjects = [UploadObject]()
        
        // Loads 'UploadObjects' from persistent memory
        if (PersistenceManager.loadNSArray(.UploadObjects) as? [UploadObject]) != nil {
            
            // Passes in all upload objects from memory
            uploadObjects = PersistenceManager.loadNSArray(.UploadObjects) as! [UploadObject]
        }
        
        // Cycles through every upload object
        for i in 0..<uploadObjects.count {
            
            // Executes when the correct upload object is found
            if uploadObject.imageName == uploadObjects[i].imageName {
                
                // Removes specific upload object
                uploadObjects.remove(at: i)
                
                // Breaks out of the for loop
                break
            }
        }
        
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Gets the location of image from the appropriate 'UploaObject'
        let fullImageURL = docURL.appendingPathComponent(uploadObject.imageLocation)

        // Gets the location of thumbnail from the appropriate 'UploaObject'
        let thumbnailURL = docURL.appendingPathComponent(uploadObject.thumbnailLocation)

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
        PersistenceManager.saveNSArray(uploadObjects as NSArray, path: .UploadObjects)

        // Takes user back to the Dashboard
        performSegue(withIdentifier: "unwindToDashboardViewController", sender: self)
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
        let fullImageURL = docURL.appendingPathComponent(uploadObject.imageLocation)
        
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
