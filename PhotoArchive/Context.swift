//
//  Context.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/19/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import Foundation

// Context objcet, which typically has Attribute objects associated with it
class Context: NSObject, NSCoding {
    
    var attributes = [Attribute]()  // Associated attributes
    var id: String                  // Identification of the context
    var descriptor = "descriptor"   // Description of the context
    
    // MARK: - Constructors
    
    init(id: String){
        self.id = id
    }
    
    init(id: String, descriptor: String){
        self.id = id
        self.descriptor = descriptor
    }
    
    init(id: String, descriptor: String, attributes: [Attribute]){
        self.id = id
        self.descriptor = descriptor
        self.attributes = attributes
        
    }
    
    // MARK: - NSCoding
    
    // Encodes the object internally to the device
    func encode(with coder: NSCoder) {
        coder.encode(self.attributes, forKey: "attributes")
        coder.encode(self.id, forKey: "id")
        coder.encode(self.descriptor, forKey: "descriptor")
    }
    
    // Decodes the object from the internal memory of the device
    required convenience init(coder decoder: NSCoder) {
        let attributes = decoder.decodeObject(forKey: "attributes") as? [Attribute]
        let id = decoder.decodeObject(forKey: "id") as? String
        let descriptor = decoder.decodeObject(forKey: "descriptor") as? String
        self.init(id: id!, descriptor: descriptor!, attributes: attributes!)
    }
}
