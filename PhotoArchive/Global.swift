//
//  Global.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/19/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import Foundation
import Photos

// Globally referenced singleton
class global {
    
    // Declare class instance property
    static let shared = global()
    
    // Declare an initializer
    // Because this class is singleton only one instance of this class can be created
    init() {}
    
    // Global variables of the application, to be passed around the different view controllers
    var tagContexts = [Context]()       // Current selected contexts
    var galleryImages = [PHAsset]()     // Images selected from the iPhoto library
    var appImages = [CameraObject]()    // Images selected from the internal application
    var cameraContexts = [Context]()    // Contexts selected on the camera tab
    
    // Global variablea of the database
    var dbContexts = [Context]()        // Contexts pulled from the database
    var dbAttributes = [Attribute]()    // Attributes pulled from the databse per appropriate context
}
