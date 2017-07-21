//
//  LoginViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 1/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//
//  NOTE: Look for the 'DEBUG MODE' notes.
//

import UIKit

class LoginViewController: UIViewController {

    // Outlets on screen
    @IBOutlet weak var inputUsername: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var rememberMeSwitchOutlet: UISwitch!
    
    // Action for the 'Remeber Me' switch
    @IBAction func rememberMeSwitchAction(_ sender: Any) {
        
    }
    
    // Action 'Login' button on screen
    @IBAction func loginButton(_ sender: Any) {
        
        // ----- START DEBUG MODE -----
        // DELETE DEBUG MODE IN PRODUCTION
        // Delete this block for normal functionality
        // Uncomment the next comment block for normal functionality
        inputUsername.text = "iOSrockzURsockz"
        // DELETE DEBUG MODE IN PRODUCTION
        // ----- END DEBUG MODE -----
        
//        // Continues executing if login was correct
//        // Currently, to log in, leave input fields blank
//        if !(inputUsername.text == "" && inputPassword.text == "") {
//            
//            // Creates an alert to notify user login was incorrect
//            let alert = UIAlertController(title: "Alert", message: "Please enter correct Information", preferredStyle: UIAlertControllerStyle.alert)
//            
//            // Creates button prompt for the alert
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
//                
//                // Dismiss alert once user acknowledges
//                alert.dismiss(animated: true, completion: nil)
//            }))
//            
//            // Present alert to the user
//            self.present(alert, animated: true, completion: nil)
//            
//            // Return to the Login view
//            return
//        }
        
        // Establish defaults object to load persistent data
        let defaults = UserDefaults.standard
        
        // Gets the pervious username, if there is one
        let previousUser = defaults.object(forKey: UD.username) as? String
        
        // Executes if this is the first time a user has ever used the application
        if previousUser == nil {
            
            // Sets up the application for first time use
            setupFirstTime(user: inputUsername.text!)
            
            // Presents the main view controller to the rest of the application
            presentMain()
        }
        // Executes if this application has been used before
        else {
            // Executes if current user is not previous user
//            if inputUsername.text! != previousUser {
            
            
                
            // ----- START DEBUG MODE -----
            // DELETE DEBUG MODE IN PRODUCTION
            // Will not execute this entire if statement
            // Delete this block for normal functionality
            // Uncomment above line for normal functionality
            if false {
            // DELETE DEBUG MODE IN PRODUCTION
            // ----- END DEBUG MODE -----
                
                
                
                // Alert to inform the user that because current user is not the previous user, all information on the application will be erased. Provide the option of cancelling the login process.
                // Create alert
                let alert = UIAlertController(title: "Different User", message: "This app is detecting that the user currently logging in is not the previous user which logged in last. Proceeding will erase all pending uploads and internal images.", preferredStyle: UIAlertControllerStyle.alert)
                
                // Add 'Proceed' button
                alert.addAction(UIAlertAction(title: "Proceed", style: UIAlertActionStyle.destructive, handler: { action in
                    
                    // Dismiss the alert once user aknowledges
                    alert.dismiss(animated: true, completion: nil)
                    
                    // Erase previous user's data
                    self.setupNewUser(user: self.inputUsername.text!)
                    
                    // Presents the main view controller to the rest of the application
                    self.presentMain()
                }))
                
                // Add 'Cancel' button
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: { action in
                    
                    // Dismiss the alert once user aknowledges
                    alert.dismiss(animated: true, completion: nil)
                    
                    // Return to the Login view
                    return
                }))
                
                // Present the alert
                self.present(alert, animated: true, completion: nil)
            }
            // Executes if current user is previous user
            else {
                
                // Save the settings for 'rememberMeSwitch'
                saveRememberMe()
                
                // Load as normal because current user is previous user
                presentMain()
            }
        }
    }
    
    // Do any additional setup after loading the view.
    override func viewDidLoad() {
        
        // Forces the view to load
        super.viewDidLoad()
        
        // Sets the 'RememberMeSwitchOutlet' to be turned on by default
        rememberMeSwitchOutlet.isOn = true
    }

    // Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        
        // Message which gives the memory warning
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated
    }
    
    // Notifies the view controller that its view was added to a view hierarchy.
    override func viewDidAppear(_ animated: Bool) {
        
        // Forces the view to appear
        super.viewWillAppear(animated)
        
        // Logs in the user immediately, if not using the app for the first time
        quickLogin()
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
    
    // MARK: - User Functions
    
    /**
     Presents the next view to the main application.
    */
    func presentMain() {
        
        // Opens up the main storyboard
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        // Sets up a connection to the main tab controller
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
        
        // Segues to the Dashboard View
        self.present(resultViewController, animated:true, completion:nil)
    }
    
    /**
     Sets up the environment for the user. Assumes the application has never been used.
     
     - Parameter user: The username of the user.
     */
    func setupFirstTime(user: String) {
        
        // Establish defaults object to load persistent data
        let defaults = UserDefaults.standard
        
        // Save the user to defaults
        defaults.set(user, forKey: UD.username)
        
        // Save the settings for 'rememberMeSwitch'
        saveRememberMe()
        
        // Create new directory in the 'Documents' directory
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docPath = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Establish URL for 'CameraImages' in 'Documents'
        let cameraImagesURL = docPath.appendingPathComponent("CameraImages")
        
        // Establish path for 'CameraImages' in 'Documents'
        let cameraImagesPath = docPath.appendingPathComponent("CameraImages").path
        
        // Establish path for 'FullImage' in 'CameraImages'
        let cameraFullImagePath = cameraImagesURL.appendingPathComponent("FullImage").path
        
        // Establish path for 'Thumbnail' in 'CameraImages'
        let cameraThumbnailPath = cameraImagesURL.appendingPathComponent("Thumbnail").path
        
        // Create 'CameraImages' directory
        do {
            try fileMngr.createDirectory(atPath: cameraImagesPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'CameraImages' directory.")
        }
        
        // Create 'FullImage' directory within 'CameraImage'
        do {
            try fileMngr.createDirectory(atPath: cameraFullImagePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'FullImage' directory.")
        }
        
        // Create 'Thumbnail' directory within 'CameraImage'
        do {
            try fileMngr.createDirectory(atPath: cameraThumbnailPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'Thumbnail' directory.")
        }
        
        // Establish URL for 'UploadImages' in 'Documents'
        let uploadImagesURL = docPath.appendingPathComponent("UploadImages")
        
        // Establish path for 'UploadImages' in 'Documents'
        let uploadImagesPath = docPath.appendingPathComponent("UploadImages").path
        
        // Establish path for 'FullImage' in 'UploadImages'
        let uploadFullImagePath = uploadImagesURL.appendingPathComponent("FullImage").path
        
        // Establish path for 'Thumbnail' in 'UploadImages'
        let uploadThumbnailPath = uploadImagesURL.appendingPathComponent("Thumbnail").path
        
        // Create the 'UploadImages' directory
        do {
            try fileMngr.createDirectory(atPath: uploadImagesPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'UploadImages' directory.")
        }
        
        // Create 'FullImage' directory within 'UploadImages'
        do {
            try fileMngr.createDirectory(atPath: uploadFullImagePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'FullImage' directory.")
        }
        
        // Create 'Thumbnail' directory within 'UploadImages'
        do {
            try fileMngr.createDirectory(atPath: uploadThumbnailPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error creating 'Thumbnail' directory.")
        }
        
        // Sets the wifi only upload setting to true by default
        defaults.set(true, forKey: UD.isWIFIOnly)
        
        // Sets the setting for images to expire
        defaults.set(true, forKey: UD.isAutoImageExpires)
        
        // Sets the time for when images will be deleted to the default 90 days
        defaults.set(90, forKey: UD.imageExpiresIn)
        
        // Sets the starting theme of the app to default
        defaults.set(0, forKey: UD.themeIndex)
    }
    
    /**
     Sets up the environment for a new user. Assumes that the application has been already used on this device.
     
     - Parameter user: The username of the user.
     */
    func setupNewUser(user: String) {
        
        // Establish defaults object to load persistent data
        let defaults = UserDefaults.standard
                
        // Save the new user to defaults
        defaults.set(user, forKey: UD.username)
        
        // Save the settings for 'rememberMeSwitch'
        saveRememberMe()
        
        // Deleting everything in the 'CameraImages' and 'UploadImages' directories
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docPath = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Establish URL for 'CameraImages' in 'Documents'
        let cameraImagesURL = docPath.appendingPathComponent("CameraImages")
        
        // Establish path for 'FullImage' in 'CameraImages'
        let cameraFullImagePath = cameraImagesURL.appendingPathComponent("FullImage").path
        
        // Establish path for 'Thumbnail' in 'CameraImages'
        let cameraThumbnailPath = cameraImagesURL.appendingPathComponent("Thumbnail").path
        
        // Delete everything in 'FullImage' directory within 'CameraImages' directory
        do {
            let filePaths = try fileMngr.contentsOfDirectory(atPath: cameraFullImagePath)
            for filePath in filePaths {
                try fileMngr.removeItem(atPath: cameraFullImagePath + "/" + filePath)
            }
        } catch {
            print("Error deleting files in 'FullImage' directory")
        }
        
        // Delete everything in 'Thumbnail' directory within 'CameraImages' directory
        do {
            let filePaths = try fileMngr.contentsOfDirectory(atPath: cameraThumbnailPath)
            for filePath in filePaths {
                try fileMngr.removeItem(atPath: cameraThumbnailPath + "/" + filePath)
            }
        } catch {
            print("Error deleting files in 'Thumbnail' directory")
        }
        
        // Establish URL for 'UploadImages' in 'Documents'
        let uploadImagesURL = docPath.appendingPathComponent("UploadImages")
        
        // Establish path for 'FullImage' in 'UploadImages'
        let uploadFullImagePath = uploadImagesURL.appendingPathComponent("FullImage").path
        
        // Establish path for 'Thumbnail' in 'UploadImages'
        let uploadThumbnailPath = uploadImagesURL.appendingPathComponent("Thumbnail").path
        
        // Delete everything in 'FullImage' directory within 'UploadImages' directory
        do {
            let filePaths = try fileMngr.contentsOfDirectory(atPath: uploadFullImagePath)
            for filePath in filePaths {
                try fileMngr.removeItem(atPath: uploadFullImagePath + "/" + filePath)
            }
        } catch {
            print("Error deleting files in 'FullImage' directory")
        }
        
        // Delete everything in 'Thumbnail' directory within 'UploadImages' directory
        do {
            let filePaths = try fileMngr.contentsOfDirectory(atPath: uploadThumbnailPath)
            for filePath in filePaths {
                try fileMngr.removeItem(atPath: uploadThumbnailPath + "/" + filePath)
            }
        } catch {
            print("Error deleting files in 'Thumbnail' directory")
        }
        
        // Sets the wifi only upload setting to true by default
        defaults.set(true, forKey: UD.isWIFIOnly)
        
        // Sets the setting for images to expire
        defaults.set(true, forKey: UD.isAutoImageExpires)
        
        // Sets the time for when images will be deleted to the default 90 days
        defaults.set(90, forKey: UD.imageExpiresIn)
        
        // Sets the starting theme of the app to default
        defaults.set(0, forKey: UD.themeIndex)
    }
    
    /**
     Immediately logs in the user based on a time stamp.
     Will not execute if this is the first time the application is being used.
     */
    func quickLogin() {
        
        // Establish defaults object to load persistent data
        let defaults = UserDefaults.standard
        
        // Gets the pervious username, if there is one
        let previousUser = defaults.object(forKey: UD.username) as? String
        
        // Gets the status of the 'rememberMeSwitch'
        let statusRememberMe = defaults.object(forKey: UD.rememberMe) as? Bool
        
        // Establishes the current date
        let currentDate = Date()
        
        // Gets the expiration date for the 'rememberMeSwitch'
        let rememberMeExpiresOn = defaults.object(forKey: UD.rememberMeExpiresOn) as? Date
        
        // Executes if this is not first time a user has ever used the application
        if previousUser != nil && statusRememberMe != nil && rememberMeExpiresOn != nil {
            
            // Executes if previous user set the 'rememberMeSwitch' to true
            if statusRememberMe! && currentDate < rememberMeExpiresOn! {
                
                // Load as normal because current user is previous user
                presentMain()
            }
                // Executes if previous user never set 'rememberMeSwitch' to true
            else {
                
                // Does not automatically log user in
                return
            }
        }
            // Executes if this is the first itme a user has ever used the application
        else {
            
            // Does not automatically log user in
            return
        }
    }
    
    /**
     Saves the date and switch setting for when the automatic login expires. 
     If it expires, the login page will force the user to login again.
     */
    func saveRememberMe() {
        
        // Establish defaults object to load persistent data
        let defaults = UserDefaults.standard
        
        // Sets the option for the 'rememberMe' switch
        defaults.set(rememberMeSwitchOutlet.isOn, forKey: UD.rememberMe)
        
        // Gets the current date
        let currentDate = Date()
        
        // Adds a month to the current date -- This is the interval for when the login will expire
        let newDate = currentDate.addingTimeInterval(60 * 60 * 24 * 30)
        
        // Sets the date to expire for 'rememberMe' switch
        defaults.set(newDate, forKey: UD.rememberMeExpiresOn)
    }
}
