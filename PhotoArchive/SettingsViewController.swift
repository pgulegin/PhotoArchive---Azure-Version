//
//  SettingsViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 1/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var imageExpiresIn: UITextField!         // Expiration for the user login
    @IBOutlet weak var autoImageDeleteOutlet: UISwitch!     // Sets the auto deletion feature
    @IBOutlet weak var wifiOnlyOutlet: UISwitch!            // Checks for uploading over wifi
    var defaults = UserDefaults()                           // User default settings
    
    // Action which determines if images are automatically deleted
    @IBAction func autoImageDeleteAction(_ sender: Any) {
        
        // Creates a value for when the image should expire
        let tempString = imageExpiresIn.text!
        let tempInt = Int(tempString)
        
        // Checks if the switch is being turned on or off
        if autoImageDeleteOutlet.isOn == true && tempInt == nil {
            autoImageDeleteOutlet.isOn = false
        }
        
        // Sets default setting
        defaults.set(autoImageDeleteOutlet.isOn, forKey: UD.isAutoImageExpires)
    }
    
    // Logs user out of application
    @IBAction func logoutAction(_ sender: Any) {
        
        // Turns off the auto login
        defaults.set(false, forKey: UD.rememberMe)
        
        // Dismisses the view controller
        dismiss(animated: true, completion: nil)
    }
    
    // Action for value when image should expire
    @IBAction func imageExpiresInEditingDidEndAction(_ sender: Any) {
        
        // Creates a new value for when the image should expire
        let tempString = imageExpiresIn.text!
        let tempInt = Int(tempString)
        
        // If expiration is not set, then grab the value from user defaults
        if tempInt != nil {
            defaults.set(tempInt, forKey: UD.imageExpiresIn)
            let tempInt = defaults.object(forKey: UD.imageExpiresIn) as! Int
            imageExpiresIn.text = String(tempInt)
        }
        else {
            // Set the value for when the image should be deleted if value is false
            autoImageDeleteOutlet.isOn = false
            defaults.set(autoImageDeleteOutlet.isOn, forKey: UD.isAutoImageExpires)
            
            imageExpiresIn.text = "X"
        }

    }
    
    // Action to check for wifi only transmission
    @IBAction func wifiOnlyAction(_ sender: Any) {
        
        // If wifi is set, turn off or vice versa
        if wifiOnlyOutlet.isOn {
            wifiOnlyOutlet.isOn = false
        }
        else {
            wifiOnlyOutlet.isOn = true
        }
        
        // Set the appropraite setting in the user defaults
        defaults.set(wifiOnlyOutlet.isOn, forKey: UD.isWIFIOnly)
    }

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        // Adds the new gesture
        view.addGestureRecognizer(tap)
        
        // Establish defaults object to load persistent data
        defaults = UserDefaults.standard
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Notifies the view controller that its view is about to be removed from a view hierarchy
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated);
        super.viewWillDisappear(animated)
    }
    
    // Notifies the view controller that its view is about to be added to a view hierarchy
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Gets whether automatic image delete is turned on
        autoImageDeleteOutlet.isOn = defaults.object(forKey: UD.isAutoImageExpires) as! Bool
        
        // Gets how many days an image will expire in
        let tempInt = defaults.object(forKey: UD.imageExpiresIn) as! Int
        imageExpiresIn.text = String(tempInt)
        
        // Sets the wifi only setting
        wifiOnlyOutlet.isOn = defaults.object(forKey: UD.isWIFIOnly) as! Bool
        
        // Sets the background color to the appropraite theme
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
    }
    
    // Dismisses the keyboard
    func dismissKeyboard() {
        
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
