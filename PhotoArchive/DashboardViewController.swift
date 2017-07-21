//
//  DashboardViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 1/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class DashboardViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    // Text labels which display the status and permission
    @IBOutlet weak var tagsStatusText: UITextField!
    @IBOutlet weak var permissionStatusText: UITextField!

    // Collection view to display all images in the upload queue
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Sets the size of the images in the cell thumbnails -- Current defaults set in the interface builder
    let thumbnailSize = CGSize(width: 80, height: 80)
    
    // All objects to be uploaded
    var uploadObjects = [UploadObject]()
    
    // Used to determine if background upload is running
    var uploading = false;
    
    // Notification icon button
    @IBOutlet weak var redirectButtonOutlet: UIButton!
    
    // Takes the user to the settings page
    @IBAction func redirectButtonAction(_ sender: Any) {
        
        // Executes if the wifi is not turned on
        if !isWIFIOn() {
            
            // Informs the user that wifi is turned off
            UIApplication.shared.open((URL(string:"App-Prefs:root=WIFI")!), options: [:], completionHandler: nil)
            
        }
            // Executes if the GPS is not turned on within the application
        else if !isGPSOn() {
            
            // Informs the user that GPS is turned off
            UIApplication.shared.open((URL(string:"App-Prefs:root=Privacy&path=LOCATION")!), options: [:], completionHandler: nil)
        }
            // Executes if the GPS is not turned on within the application
        else if !isPhotosOn() {
            
            // Informs the user that there is no access to iPhone photos
            UIApplication.shared.open((URL(string:"App-Prefs:root=Privacy&path=PHOTOS")!), options: [:], completionHandler: nil)
        }
            // Executes if the GPS is not turned on within the application
        else if !isCameraOn() {
            
            // Informs user that camera functionality is not allowed
            UIApplication.shared.open((URL(string:"App-Prefs:root=Privacy&path=CAMERA")!), options: [:], completionHandler: nil)
        }
            // Executes if everything is set up correctly
        else {
            redirectButtonOutlet.isHidden = true
        }
    }
    
    // Clears out all of the upload objects
    @IBAction func clearUploadQueueAction(_ sender: Any) {
        
        // Loads 'UploadObjects' from persistent memory
        if (PersistenceManager.loadNSArray(.UploadObjects) as? [UploadObject]) != nil {
            uploadObjects = PersistenceManager.loadNSArray(.UploadObjects) as! [UploadObject]
        }
        
        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docPath = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
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
        
        // Removes all of the objects
        uploadObjects.removeAll()
        
        // Saves the empty UploadObjects to memory
        PersistenceManager.saveNSArray(uploadObjects as NSArray, path: .UploadObjects)
        
        // Reload the collectionView
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tagsStatusText.text = "Syncing..."

        //Pull Contexts from DB and save to global variable
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let client = delegate.client!;
        
        let contextTable = client.table(withName: "Context");
        
        contextTable.read(completion: {
            (result, error) in
            if let contextResults = result?.items {
                for context in contextResults {
                    global.shared.dbContexts.append(
                        Context(
                            id: context["id"] as! String,
                            descriptor: context["descriptor"] as! String
                        )
                    )
                }
                
                self.tagsStatusText.text = "Up To Date"
            }
        })
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(DashboardViewController.applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hides the navigation controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Loads 'UploadObjects' from persistent memory
        if (PersistenceManager.loadNSArray(.UploadObjects) as? [UploadObject]) != nil {
            uploadObjects = PersistenceManager.loadNSArray(.UploadObjects) as! [UploadObject]
        }
        
        // Reloads Dashboard collection view
        collectionView.reloadData()
        
        // Updates permissions
        updatePermissions()
        
        view.backgroundColor = ThemeManager.applyBackground(theme: UserDefaults.standard.object(forKey: UD.themeIndex) as? Int ?? 0)
        
        //try to upload
        if(!uploading && !self.uploadObjects.isEmpty){
            uploadToAzure();
        }
    }
    
    func uploadToAzure(){
        self.uploading = true;
        
        //setup Azure information
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        let client = delegate.client!;
        
        let imageTable = client.table(withName: "Image");
        let icavTable = client.table(withName: "ICAV");
        
        let sas = "sv=2016-05-31&ss=b&srt=o&sp=rw&se=2027-02-24T00:00:00Z&st=2017-02-24T00:00:00Z&spr=https&sig=kChTx0B8faa43g%2F%2F2G5LIWBCOKMxq1eIgqOUn9Ds9s4%3D"
        
        let account = try! AZSCloudStorageAccount(fromConnectionString: "SharedAccessSignature=" + sas + ";BlobEndpoint=https://boephotostore.blob.core.windows.net")
        
        let blobClient = account.getBlobClient()!
        
        let blobContainer = blobClient.containerReference(
            fromName:"photocontainer"
        );
        
        //Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let user = UserDefaults.standard.string(forKey: UD.username)!
        
        //initiate image table, check if initaited
        //initiate icav table, check if initaited
        //initiate img blob, check if initaited
        //initiate thumb blob, check if initaited
        
        //check if they are all complete
        //if complete, move to next image
        
        DispatchQueue.global(qos: .utility).async {
            //Control booleans
            var imageTableStarted = false;
            var icavTableStarted = false;
            var imageBlobStarted = false;
            var thumbnailBlobStarted = false;
            
            var imageTableDone = false;
            var icavTableDone = false;
            var imageBlobDone = false;
            var thumbnailBlobDone = false;
            
            //used to keep track of ICAV Row inserts
            var rowCount = 0;
            //will be updated to correct value on first pass
            var totalRows = 0;
            
            while(self.isWIFIOn() && !self.uploadObjects.isEmpty){
                //grab first image in list
                let image = self.uploadObjects[0];
                
                //----BEGIN IMAGE TABLE SECTION----
                if(!imageTableStarted){
                    
                    imageTableStarted = true;
                    
                    let imageRow = [
                        "id" : user + "_" + image.imageName,
                        "userID" : user,
                        "lat" : image.latitude,
                        "lon" : image.longitude
                    ] as [String : Any]
                    
                    imageTable.insert(imageRow, completion:{
                        (result, error) in
                        
                        if let err = error as NSError? {
                            let errorCode = (err.userInfo["com.Microsoft.MicrosoftAzureMobile.ErrorResponseKey"] as! HTTPURLResponse).statusCode;
                            
                            if(errorCode == 409){
                                //image already exists, no use reinserting
                                //we're pretty much done
                                imageTableDone = true;
                            }else{
                                //some other error :/
                                print("Error: ", err);
                            }
                            
                        } else {
                            //move on to ICAV
                            imageTableDone = true;
                        }
                    })
                    
                    
                }
                //----END IMAGE TABLE SECTION----
                
                //----BEGIN ICAV TABLE SECTION----
                if(!icavTableStarted && imageTableDone){
                    
                    icavTableStarted = true;
                    
                    for context in image.contexts{
                        for attribute in context.attributes{
                            //update total rows
                            totalRows += 1;
                            
                            let icavRow = [
                                "imageID" : user + "_" + image.imageName,
                                "contextID" : context.id,
                                "attributeID" : attribute.id,
                                "value" : attribute.value
                                ] as [String : Any]
                            
                            icavTable.insert(icavRow, completion:{
                                (result, error) in
                                
                                if let err = error as NSError?{
                                    let errorCode = (err.userInfo["com.Microsoft.MicrosoftAzureMobile.ErrorResponseKey"] as! HTTPURLResponse).statusCode;
                                    
                                    if(errorCode == 409){
                                        //image already exists, no use reinserting
                                        //we're pretty much done
                                        rowCount += 1;
                                    }else{
                                        //some other error :/
                                    }
                                    
                                } else {
                                    //inserted successfully
                                    rowCount += 1;
                                }
                            })
                        }
                    }
                }
                
                if(!icavTableDone){
                    if(rowCount == totalRows){
                        icavTableDone = true;
                    }
                }
                //----END ICAV TABLE SECTION----
                
                
                //----BEGIN BLOB SECTION----
                
                //  ---Image Blob---
                
                if(!imageBlobStarted){
                    
                    imageBlobStarted = true;
                    
                    let imagePath = docURL.appendingPathComponent(image.imageLocation)
                    let imageData = NSData(contentsOfFile: imagePath.path)!
                    
                    let imageReference = user + "/" + image.imageName;
                    
                    let imageBlob = blobContainer.blockBlobReference(fromName: imageReference);
                    
                    imageBlob.upload(from: imageData as Data, completionHandler: {
                        (error) in
                        if error != nil{
                            print("Image Blob Error: ", error);
                        }else{
                            imageBlobDone = true;
                        }
                    })
                    
                }
                
                //  ---End Image Blob---
                
                //  ---Thumbnail Blob---
                
                if(!thumbnailBlobStarted){
                    thumbnailBlobStarted = true;
                    
                    let thumbnailPath = docURL.appendingPathComponent(image.thumbnailLocation)
                    
                    // Grab image data
                    let thumbnailData = NSData(contentsOfFile: thumbnailPath.path)!
                    
                    let thumbnailReference = user + "/thumbnails/" + image.imageName;
                    
                    let thumbnailBlob = blobContainer.blockBlobReference(fromName: thumbnailReference);
                    
                    thumbnailBlob.upload(from: thumbnailData as Data, completionHandler: {
                        (error) in
                        if error != nil{
                            print("Thumbnail Blob Error: ", error);
                        }else{
                            thumbnailBlobDone = true;
                        }
                    })
                }
                
                //  ---End Thumbnail Blob---
                
                //----END BLOB SECTION----
                
                //---ALL DONE SECTION---
                
                if(imageTableDone && icavTableDone && imageBlobDone && thumbnailBlobDone){
                    
                    DispatchQueue.main.async {
                        if(!self.uploadObjects.isEmpty){
                            self.uploadObjects.remove(at: 0);
                            
                            //update persistant version
                            PersistenceManager.saveNSArray(self.uploadObjects as NSArray, path: .UploadObjects)
                            
                            self.collectionView.reloadData();
                        }
                    }
                    
                    //reset bools
                    imageTableStarted = false;
                    icavTableStarted = false;
                    imageBlobStarted = false;
                    thumbnailBlobStarted = false;
                    
                    imageTableDone = false;
                    icavTableDone = false;
                    imageBlobDone = false;
                    thumbnailBlobDone = false;
                }
                
                //sleep so application doesnt lag insanely
                //sleep for .05 seconds
                usleep(500);
            }
            
            if(self.uploadObjects.isEmpty){
                self.uploading = false;
            }
        }
    }
    
    // Function is specifically called if the application is interrupted
    @objc private func applicationDidBecomeActive(_ notification: NSNotification) {
        
        // Updates permissions
        updatePermissions()
    }
    
    // Asks your data source object for the number of items in the specified section
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // The amount of objects to be displayed
        return uploadObjects.count
    }
    
    // Asks your data source object for the cell that corresponds to the specified item in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Establish current object of this cell
        let object = uploadObjects[indexPath.row]
        
        // Cell configuration
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "dashboardCell", for: indexPath) as! DashboardCollectionViewCell

        // Establish FileManager object
        let fileMngr = FileManager.default
        
        // Establish path to 'Documents'
        let docURL = fileMngr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Gets location of the image
        let thumbnailPath = docURL.appendingPathComponent(object.thumbnailLocation)
        
        // Imports image
        let image = UIImage(contentsOfFile: thumbnailPath.path)!
        
        // Adds image to cell
        cell.imageView.image = image
        
        // Returns the cell to be loaded
        return cell
        
    }
    
    // Tells the delegate that the item at the specified index path was selected
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Performs the segue to view the main object
        self.performSegue(withIdentifier: "dashboardShowImage", sender: self)
    }
    
    
    // MARK: - Navigation
    
    /**
     Prepares for a segue transition from the Dashboard to the ImageViewer.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Gets the indexPath of the selected cell
        let indexPath = collectionView.indexPathsForSelectedItems![0]
        
        // Establishes next view controller to be 'DashboardImageViewController'
        let nextViewController = segue.destination as! DashboardImageViewController
        
        // Passes in the obect to be displayed
        nextViewController.uploadObject = uploadObjects[indexPath.row]
    }
    
    // Prepares for a segue transition from the Attribute pages
    @IBAction func unwindToDashboardViewController(segue:UIStoryboardSegue) {}
    
    
    // MARK: - User Functions
    
    /**
        Check to see if wifi is available.
     
        - Returns: Bool: true if wifi is active; false if it is not
     */
    func isWIFIOn() -> Bool {
        
        // Checks to see what the user has set on the Settings page
        // Executes if user has only wifi turned to on
        let wifiOn = UserDefaults.standard.object(forKey: UD.isWIFIOnly) as? Bool
        
        if wifiOn != nil && wifiOn! == true {
            
            // Establish object to check status of wifi
            let reachability = Reachability()!
            
            // Executes if wifi is connected
            if reachability.isReachableViaWiFi {
                
                // Returns true
                return true
            }
            // Executes if wifi is not connected
            else {
                
                // Returns false
                return false
            }
        }
        // Executes if user is willing to upload over any connection
        else {
            
            // Returns true
            return true
        }
    }
    
    /**
     Check to see if GPS is available.
     
     - Returns: Bool: true if GPS is active; false if it is not
     */
    func isGPSOn() -> Bool {
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .notDetermined, .restricted, .denied:
                return false
            case .authorizedAlways, .authorizedWhenInUse:
                return true
            }
        }
        else {
            return false
        }
    }
    
    /**
     Check to see if Photos are available.
     
     - Returns: Bool: true if Photos are active; false if it is not
     */
    func isPhotosOn() -> Bool {
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            return true
        }
        else {
            return false
        }
    }
    
    /**
     Check to see if Camera is available.
     
     - Returns: Bool: true if Camera is active; false if it is not
     */
    func isCameraOn() -> Bool {
        
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
        {
            return true
        }
        else {
            return false
        }
    }
    
    /**
        This should be called whenever there is a check to make sure the permissions are set up correctly.
     */
    func updatePermissions() {
        
        // Executes if the wifi is not turned on
        if !isWIFIOn() {
        
            // Informs the user that wifi is turned off
            permissionStatusText.text = "Wifi is off"
            
        }
        // Executes if the GPS is not turned on within the application
        else if !isGPSOn() {
            
            // Informs the user that GPS is turned off
            permissionStatusText.text = "GPS is turned off"
        }
        // Executes if the GPS is not turned on within the application
        else if !isPhotosOn() {
            
            // Informs the user that there is no access to iPhone photos
            permissionStatusText.text = "No photos access"
        }
        // Executes if the GPS is not turned on within the application
        else if !isCameraOn() {
            
            // Informs user that camera functionality is not allowed
            permissionStatusText.text = "No camera access"
        }
        // Executes if everything is set up correctly
        else {
            permissionStatusText.text = " Correct"
            redirectButtonOutlet.isHidden = true
        }
    }
}
