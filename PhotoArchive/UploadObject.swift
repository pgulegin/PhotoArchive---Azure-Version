//
//  UploadObject.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/24/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import Foundation
import Photos

// Object which has been prepped and is now ready to be uploaded into the database
class UploadObject: NSObject, NSCoding {
    
    var imageName: String           // Name of the image
    var imageLocation: String       // Location of where the image is internally in the application
    var thumbnailLocation: String   // Location of where the thumbanil image is internally in the application
    var latitude: Double            // Latitude of the location where the image was taken
    var longitude: Double           // Longitude of the location where the image was taken
    var contexts = [Context]()      // Contexts assocaited with this image, which has its own associated attributes
    
    
    // Constructor
    init(imageName: String, imageLocation: String, thumbnailLocation: String, latitude: Double, longitude: Double, contexts: [Context]) {
        self.imageName = imageName
        self.imageLocation = imageLocation
        self.thumbnailLocation = thumbnailLocation
        self.latitude = latitude
        self.longitude = longitude
        self.contexts = contexts
    }
    
    // Debug - Prints out the information of a particular object
    func info() {
        print("imageName: ", imageName)
        print("imageLocation: ", imageLocation)
        print("thumbnailLocation: ", thumbnailLocation)
        print("latitude:  ", latitude)
        print("longitude: ", longitude)
        print("contexts:  ", contexts)
    }
    
    // MARK: - NSCoding
    
    // Encodes the object internally to the device
    func encode(with coder: NSCoder) {
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.imageLocation, forKey: "imageLocation")
        coder.encode(self.thumbnailLocation, forKey: "thumbnailLocation")
        coder.encode(self.latitude, forKey: "latitude")
        coder.encode(self.longitude, forKey: "longitude")
        coder.encode(self.contexts, forKey: "contexts")
    }
    
    // Decodes the object from the internal memory of the device
    required convenience init(coder decoder: NSCoder) {
        let imageName = decoder.decodeObject(forKey: "imageName") as! String
        let imageLocation = decoder.decodeObject(forKey: "imageLocation") as! String
        let thumbnailLocation = decoder.decodeObject(forKey: "thumbnailLocation") as! String
        let latitude = decoder.decodeDouble(forKey: "latitude")
        let longitude = decoder.decodeDouble(forKey: "longitude")
        let contexts = decoder.decodeObject(forKey: "contexts") as! [Context]
        self.init(imageName: imageName, imageLocation: imageLocation, thumbnailLocation: thumbnailLocation, latitude: latitude, longitude: longitude, contexts: contexts)
    }
}
