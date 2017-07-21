//
//  TaggingSelectedContextsAttributesTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/20/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingSelectedContextsAttributesTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var contextTitle: UINavigationItem!  // Title of the context
    var context = 0                                     // Number of contexts
    var currentContext:Context!                         // Currently selected context
    var attributes = [String]()                         // Attributes showed
    var descriptions = [String]()                       // Description of the attributes
    var answers = [String]()                            // Answers for the attributes
    
    // Action which saves the attribute answers
    @IBAction func saveButton(_ sender: Any) {
        
        // Removes the current context
        global.shared.tagContexts.remove(at: context)
        
        // Creates a Context object with the title of the current context
        let tempContext = Context(id: contextTitle.title!)
        
        for index in 0..<attributes.count {
            let tempAttribute = Attribute(id: attributes[index], question: descriptions[index], value: answers[index])
            tempContext.attributes.append(tempAttribute)
        }

        // Adds in the appropraite context
        global.shared.tagContexts.insert(tempContext, at: context)
        
        // Unwinds to the previous view controller
        performSegue(withIdentifier: "unwindToTaggingViewController", sender: self)
    }
    
    // Action to delete the selected context
    @IBAction func deleteButton(_ sender: Any) {
        
        // Removes selected context
        global.shared.tagContexts.remove(at: context)

        // Unwinds to the previous view controller
        performSegue(withIdentifier: "unwindToTaggingViewController", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        // Pulls the context and the title for the contexts
        currentContext = global.shared.tagContexts[context]
        contextTitle.title = global.shared.tagContexts[context].id
        
        // Appes the Attribute's attributes
        for i in 0..<global.shared.tagContexts[context].attributes.count {
            attributes.append(global.shared.tagContexts[context].attributes[i].id)
            descriptions.append(global.shared.tagContexts[context].attributes[i].question)
            answers.append(global.shared.tagContexts[context].attributes[i].value)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Numbers of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentContext.attributes.count
    }

    // Configure the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Prepares the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaggingSelectedContextsAttributesTableViewCell", for: indexPath) as! TaggingSelectedContextsAttributesTableViewCell

        // Displays the title and the description of the attribute
        cell.attributeTitle.text = attributes[indexPath.row]
        cell.attributeDescription.text = descriptions[indexPath.row]
        cell.attributeAnswer.text = answers[indexPath.row]
        
        // Cell debug to save textview data
        cell.attributeAnswer.tag = indexPath.row
        cell.attributeAnswer.delegate = self
        
        // Prevents the cell from being selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        

        return cell
    }
    
    // Prevents the cell from being highlighted when selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // Saves the answers whenever they are changed
    func textViewDidChange(_ textView: UITextView) {
        answers[textView.tag] = textView.text!
    }
    
    // Dismisses the keyboard when editing changes
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
