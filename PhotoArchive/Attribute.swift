//
//  Attribute.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/19/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import Foundation

// Attribute object, which is typically associated with a context
class Attribute: NSObject, NSCoding {
    var id = "default"          // Identification of the attribute
    var question = "default"    // Question presented to the user
    var value = "default"       // Answer written by the user
    
    // Constructor
    init(id: String, question: String, value: String) {
        self.id = id
        self.question = question
        self.value = value
    }
    
    // MARK: - NSCoding
    
    // Encodes the object internally to the device
    func encode(with coder: NSCoder) {
        coder.encode(self.id, forKey: "id")
        coder.encode(self.question, forKey: "question")
        coder.encode(self.value, forKey: "value")
    }
    
    // Decodes the object from the internal memory of the device
    required convenience init(coder decoder: NSCoder) {
        let id = decoder.decodeObject(forKey: "id") as? String
        let question = decoder.decodeObject(forKey: "question") as? String
        let value = decoder.decodeObject(forKey: "value") as? String
        self.init(id: id!, question: question!, value: value!)
    }
}
