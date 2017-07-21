//
//  CameraSelectedContextsAttributesTableTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/26/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class CameraSelectedContextsAttributesTableTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet weak var contextTitle: UINavigationItem!  // Context title to be displayed
    var context = 0                                     // Selected context
    var currentContext:Context!                         // Context object to hold the selected context
    
    var attributes = [String]()                         // Attributes for the selected context
    var descriptions = [String]()                       // Descriptions for the selected context
    var answers = [String]()                            // Answer boxes for user's response
    
    // Action to save the current context
    @IBAction func saveButton(_ sender: Any) {
        
        // Global list of context object created through the camera
        global.shared.cameraContexts.remove(at: context)
        
        // Creates a Context object with the title of the current context
        let tempContext = Context(id: contextTitle.title!)
        
        // Creates a list of attributes for the context
        for index in 0..<attributes.count {
            let tempAttribute = Attribute(id: attributes[index], question: descriptions[index], value: answers[index])
            tempContext.attributes.append(tempAttribute)
        }
        
        // Replaces the selected context
        global.shared.cameraContexts.insert(tempContext, at: context)
        
        // Unwinds to the previous controller
        performSegue(withIdentifier: "unwindToCameraViewController", sender: self)
    }
    
    // Action to delete the current context
    @IBAction func deleteButton(_ sender: Any) {
        
        // Remove the current selected context
        global.shared.cameraContexts.remove(at: context)
        
        // Unwind to the previous view controller
        performSegue(withIdentifier: "unwindToCameraViewController", sender: self)
    }
    
    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Looks for single or multiple taps
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        // Creates the new gesture
        view.addGestureRecognizer(tap)
        
        // Grabs the current context and title
        currentContext = global.shared.cameraContexts[context]
        contextTitle.title = global.shared.cameraContexts[context].id
        
        // Cycles through all of the attributes for that context
        for i in 0..<global.shared.cameraContexts[context].attributes.count {
            
            // Appends the appropriate responses for the context
            attributes.append(global.shared.cameraContexts[context].attributes[i].id)
            descriptions.append(global.shared.cameraContexts[context].attributes[i].question)
            answers.append(global.shared.cameraContexts[context].attributes[i].value)
        }
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Asks the data source to return the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Returns the number of rows (table cells) in a specified section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return currentContext.attributes.count
    }

    // Asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creates the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraSelectedContextsAttributesTableViewCell", for: indexPath) as! CameraSelectedContextsAttributesTableViewCell
        
        // Displays the title and the description of the attribute
        cell.attributeTitle.text = attributes[indexPath.row]
        cell.attributeDescription.text = descriptions[indexPath.row]
        cell.attributeAnswer.text = answers[indexPath.row]
        
        // Cell debug to save textview data
        cell.attributeAnswer.tag = indexPath.row
        cell.attributeAnswer.delegate = self
        
        // Prevents the cell from being selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        // Returns the appropriate cell
        return cell
    }
    
    // Prevents the cell from being highlighted when selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // Tells the delegate that the text or attributes in the specified text view were changed by the user
    func textViewDidChange(_ textView: UITextView) {
        answers[textView.tag] = textView.text!
    }
    
    // Dismisses the keyboard
    func dismissKeyboard() {
        
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
