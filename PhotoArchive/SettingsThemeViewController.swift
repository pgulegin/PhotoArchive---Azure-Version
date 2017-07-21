//
//  SettingsThemeViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 5/3/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class SettingsThemeViewController: UIViewController {
    
    @IBOutlet weak var segmentOutlet: UISegmentedControl!   // Segment of the currently selected theme

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()

        // Grabs the currently selected index
        segmentOutlet.selectedSegmentIndex = UserDefaults.standard.object(forKey: UD.themeIndex) as! Int
        
        // Changes the background to theme color
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Action which selects different theme
    @IBAction func segmentAction(_ sender: Any) {
        
        // Saves the theme to User Defaults
        UserDefaults.standard.set(segmentOutlet.selectedSegmentIndex, forKey: UD.themeIndex)
        
        // Reloads the view
        self.viewWillAppear(true)
    }
    
    // Notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated);

        // Applies the correct theme
        ThemeManager.applyTheme(theme: segmentOutlet.selectedSegmentIndex)

        // Selects the correct background color
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }
    
    // Notifies the view controller that its view is about to be removed from a view hierarchy
    override func viewWillDisappear(_ animated: Bool) {
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }

    // Applies the correct theme and dismisses the view
    @IBAction func applyAction(_ sender: Any) {
        
        // Dismisses the view to the previous view controller
        self.dismiss(animated: true, completion: nil)
    }
}
