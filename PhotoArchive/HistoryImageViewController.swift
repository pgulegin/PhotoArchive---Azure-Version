//
//  HistoryImageViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/11/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit
import Kingfisher

class HistoryImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!  // Displays the image
    var imagePath: String?                      // String to the image path
    var imageContexts = [String]()              // Contexts associated with the image
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load full image from kingfisher
        let url = URL(string: self.imagePath!)
        
        // Set the activity of the image
        self.imageView?.kf.indicatorType = .activity
        
        // Load the image from cache
        let image = ImageCache.default.retrieveImageInDiskCache(forKey: url!.absoluteString)
        
        // Handles the image not loading
        if(image == nil){
            self.imageView?.kf.setImage(with: url, options: [.transition(.fade(0.2)),.forceRefresh])
        }
        else{
            self.imageView.image = image
        }
        
        // Main application delegate
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        // Client to communicate with the database
        let client = delegate.client!
        
        // Loads the association table
        let icavTable = client.table(withName: "ICAV");
        
        // Creates a query to search for current images contexts and attributes
        let icavQuery = icavTable.query();
        icavQuery.predicate = NSPredicate(format: "imageID == %@", self.title!);
        icavQuery.selectFields = ["contextID"]
        
        // Reads from the query
        icavQuery.read(completion: {
            (result, error) in
            if let contextResults = result?.items {
                print(contextResults.count);
                
                // Loads multiple contexts
                for row in contextResults {
                    let context = row["contextID"] as! String;
                    
                    // Appends the contexts
                    if(!self.imageContexts.contains(context)){
                        self.imageContexts.append(context)
                    }
                }
            }
        })
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
    // Notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Changes the background color to the theme currently in use
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }
    
    // Prepares for a transition to another view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        // Verifies the correct corrent view controller
        if segue.identifier == "historyShowTagsSeque" {
            
            // Creates the new view controller
            let vc = segue.destination as! HistoryTagTableViewController
            
            // Passes in the contexts and title of the image to the next controller
            vc.contexts = imageContexts
            vc.imageTitle = self.title
        }
    }
}
