//
//  CameraObject.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/24/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import Foundation
import Photos

// Object created when the user takes a picture from within the applications
class CameraObject: NSObject, NSCoding {
    
    // Object variables
    var imageName: String           // Name of the image
    var imageLocation: String       // Location of full resolution image within the device
    var thumbnailLocation: String   // Location of thumbnail image within the device
    var latitude: Double            // Latitude of where image was taken
    var longitude: Double           // Longitude of where image was taken
    
    // Constructor
    init(imageName: String, imageLocation: String, thumbnailLocation: String, latitude: Double, longitude: Double) {
        self.imageName = imageName
        self.imageLocation = imageLocation
        self.thumbnailLocation = thumbnailLocation
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // Checks for equality between two objects
    override func isEqual(_ object: Any?) -> Bool {
        return imageName == (object as? CameraObject)?.imageName
    }
    
    // Debug - Prints out the information of a particular object
    func info() {
        print("imageName:         ", imageName)
        print("imageLocation:     ", imageLocation)
        print("thumbnailLocation: ", thumbnailLocation)
        print("latitude:          ", latitude)
        print("longitude:         ", longitude)
    }
    
    // MARK: - NSCoding
    
    // Encodes the object internally to the device
    func encode(with coder: NSCoder) {
        coder.encode(self.imageName, forKey: "imageName")
        coder.encode(self.imageLocation, forKey: "imageLocation")
        coder.encode(self.thumbnailLocation, forKey: "thumbnailLocation")
        coder.encode(self.latitude, forKey: "latitude")
        coder.encode(self.longitude, forKey: "longitude")
    }
    
    // Decodes the object from the internal memory of the device
    required convenience init(coder decoder: NSCoder) {
        let imageName = decoder.decodeObject(forKey: "imageName") as! String
        let imageLocation = decoder.decodeObject(forKey: "imageLocation") as! String
        let thumbnailLocation = decoder.decodeObject(forKey: "thumbnailLocation") as! String
        let latitude = decoder.decodeDouble(forKey: "latitude")
        let longitude = decoder.decodeDouble(forKey: "longitude")
        self.init(imageName: imageName, imageLocation: imageLocation, thumbnailLocation: thumbnailLocation, latitude: latitude, longitude: longitude)
    }
}
