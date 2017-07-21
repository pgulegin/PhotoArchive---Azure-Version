//
//  CameraAttributeTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/25/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class CameraAttributeTableViewController: UITableViewController, UITextViewDelegate {

    // Database connection variables
    let delegate = UIApplication.shared.delegate as! AppDelegate    // Main application delegate
    var client: MSClient!                                           // Client variable for database
    
    // Passed in context
    @IBOutlet weak var contextTitle: UINavigationItem!
    
    // Attribute titles
    var attributes = [Attribute]();
    
    // Action to save the current context object
    @IBAction func saveButton(_ sender: Any) {
        
        // Creates a context object with the title of the current context
        let tempContext = Context(id: contextTitle.title!)
        
        for index in 0..<attributes.count {
            let tempAttribute = attributes[index]
            tempContext.attributes.append(tempAttribute)
        }
        
        // Appends the context to the global camera contexts
        global.shared.cameraContexts.append(tempContext)
        
        // Performs an unwind segue to the previous controller
        performSegue(withIdentifier: "unwindToCameraViewController", sender: self)
    }
    
    // Update all of the attributes for the table
    func updateAttributeList(list: [Attribute]) {
        
        // Populates the attributes
        attributes = list;
        
        // Reloads the data table
        self.tableView.reloadData()
    }

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        // Adds a new gesture
        view.addGestureRecognizer(tap)
        
        // Store the client from delegate
        client = delegate.client!;
        
        // Create a Context_Attribute table object
        let caTable = client.table(withName: "Context_Attribute");
        
        // Create a query to only pull attribute IDs for the specific context
        let caQuery = caTable.query();
        caQuery.predicate = NSPredicate(format: "contextID == %@", contextTitle.title!);
        
        // Create an array to store the pulled IDs
        var attributeIDs = [String]();
        
        // Run the query
        caQuery.read(completion: {
            (result, error) in
            
            if let err = error{
                print("ERROR ", err);
            } else if let caResults = result?.items{
                for caResult in caResults{
                    attributeIDs.append(caResult["attributeID"] as! String);
                }
            }
            
            // After the query is done, create the attribute list from those IDs
            self.createAttributeList(list: attributeIDs);
        })
    }
    
    // Function to create Attribute object list from list of IDs
    func createAttributeList(list: [String]){
        
        // Create reference to attribute table
        let attributeTable = client.table(withName: "Attribute");
        
        // Create a query object
        let attributeQuery = attributeTable.query();
        
        // Limit it to pull only the question
        attributeQuery.selectFields = ["question"];
        
        for attributeID in list{
            
            // Predicate forces ID to match current loop ID - SHOULD ONLY RETURN ONE RECORD PER LOOP
            attributeQuery.predicate = NSPredicate(format: "id == %@", attributeID);
            
            // Run the query
            attributeQuery.read(completion: {
                (result, error) in
                if let err = error {
                    print("ERROR ", err)
                } else if let attributeResults = result?.items {
                    
                    // Create a new attribute object and set the id
                    let newAttribute = Attribute(id: attributeID, question: "", value: "");
                    
                    // Update the question
                    for attribute in attributeResults {
                        newAttribute.question = attribute["question"] as! String
                    }
                    
                    // Update UI (SLOW PART, since it's one at a time :/ )
                    self.updateAttributeList(attribute: newAttribute);
                }
            })
        }
    }

    // Update all of the attributes for the table
    func updateAttributeList(attribute: Attribute){
        
        // Appends a new attribute to the list of attributes
        attributes.append(attribute);
        
        // Sorts the attribute
        attributes = attributes.sorted{$0.id.localizedCompare($1.id) == .orderedAscending}
        
        // Reloads data in the table
        self.tableView.reloadData()
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Asks the data source to return the number of sections in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // Returns the number of rows (table cells) in a specified section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return attributes.count
    }

    // Asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creates the cell to modify
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraAttributeTableViewCell", for: indexPath) as! CameraAttributeTableViewCell
        
        // Displays the title and the description of the attribute
        cell.attributeTitle.text = attributes[indexPath.row].id
        cell.attributeDescription.text = attributes[indexPath.row].question
        cell.attributeAnswer.text = attributes[indexPath.row].value
        
        // Cell debug to save textview data
        cell.attributeAnswer.tag = indexPath.row
        cell.attributeAnswer.delegate = self
        
        // Prevents the cell from being selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Returns the cell
        return cell
    }
    
    // Prevents the cell from being highlighted when selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // Tells the delegate that the text or attributes in the specified text view were changed by the user
    func textViewDidChange(_ textView: UITextView) {
        attributes[textView.tag].value = textView.text!
    }
}
