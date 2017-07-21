//
//  AttributeTableTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/18/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class AttributeTableTableViewController: UITableViewController, UITextViewDelegate {
    
    let delegate = UIApplication.shared.delegate as! AppDelegate    // Main delegate
    var client: MSClient!                                           // Azure client
    @IBOutlet weak var contextTitle: UINavigationItem!              // Passed in context
    var attributes = [Attribute]()                                  // Attribute for the context
    
    // Action to save attribute answers
    @IBAction func saveButton(_ sender: Any) {
        
        // Creates a Context object with the title of the current context
        let tempContext = Context(id: contextTitle.title!)
        
        for index in 0..<attributes.count {
            let tempAttribute = attributes[index]
            tempContext.attributes.append(tempAttribute)
        }
        
        // Adds the context to the global contexts
        global.shared.tagContexts.append(tempContext)
        
        // Unwinds to the previous view controller
        performSegue(withIdentifier: "unwindToTaggingViewController", sender: self)
    }
    
    // Updates the attributes in the view
    func updateAttributeList(attribute: Attribute) {
        
        // Appends the new attribute
        attributes.append(attribute);
        
        // Sorts the attribute in alphabetical order
        attributes = attributes.sorted{$0.id.localizedCompare($1.id) == .orderedAscending}
        
        // Reolads the table
        self.tableView.reloadData()
        
    }
    
    // Function to create Attribute object list from list of IDs
    func createAttributeList(list: [String]){
        //create reference to attribute table
        let attributeTable = client.table(withName: "Attribute");
        
        //create a query object
        let attributeQuery = attributeTable.query();
        
        //limit it to pull only the question
        attributeQuery.selectFields = ["question"];
        
        for attributeID in list{
            //predicate forces ID to match current loop ID
            //SHOULD ONLY RETURN ONE RECORD PER LOOP
            attributeQuery.predicate = NSPredicate(format: "id == %@", attributeID);
            
            //run the query
            attributeQuery.read(completion: {
                (result, error) in
                if let err = error {
                    print("ERROR ", err)
                } else if let attributeResults = result?.items {
                    
                    //create a new attribute object and set the id
                    let newAttribute = Attribute(id: attributeID, question: "", value: "");
                    
                    //update the question
                    for attribute in attributeResults {
                        newAttribute.question = attribute["question"] as! String
                    }
                    
                    //update UI (SLOW PART, since it's one at a time :/ )
                    self.updateAttributeList(attribute: newAttribute);
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
        
        //store the client from delegate
        client = delegate.client!;
        
        //create a Context_Attribute table object
        let caTable = client.table(withName: "Context_Attribute");
        
        //create a query to only pull attribute IDs for the specific context
        let caQuery = caTable.query();
        caQuery.predicate = NSPredicate(format: "contextID == %@", contextTitle.title!);
        
        //create an array to store the pulled IDs
        var attributeIDs = [String]();
        
        //run the query
        caQuery.read(completion: {
            (result, error) in
            
            if let err = error{
                print("ERROR ", err);
            } else if let caResults = result?.items{
                for caResult in caResults{
                    attributeIDs.append(caResult["attributeID"] as! String);
                }
            }
            
            //after the query is done, create the attribute list from those IDs
            self.createAttributeList(list: attributeIDs);
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Sets the number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // Sets the number of rows per section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count
    }

    // Configures the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttributeTableViewCell", for: indexPath) as! AttributeTableViewCell
        
        // Displays the title and the description of the attribute
        cell.attributeTitle.text = attributes[indexPath.row].id
        cell.attributeDescription.text = attributes[indexPath.row].question
        cell.attributeAnswer.text = attributes[indexPath.row].value
        
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
    
    // Saves the answer whenever the attribute changes
    func textViewDidChange(_ textView: UITextView) {
        attributes[textView.tag].value = textView.text!
    }
    
    // Dismisses the keyboard
    func dismissKeyboard() {
        // Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
