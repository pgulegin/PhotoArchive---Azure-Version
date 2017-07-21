//
//  HistoryAttributeTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/18/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class HistoryAttributeTableViewController: UITableViewController {
    
    @IBOutlet weak var contextTitle: UINavigationItem!  // Passed in context from the previous view controller
    var imageTitle: String!                             // Title of the image
    var attributes = [String]()                         // Attribute titles
    var values = [String: String]()                     // Attribute values

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Main application delegate
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        // Client connection with the database
        let client = delegate.client!
        
        // Loads the association table
        let icavTable = client.table(withName: "ICAV");
        
        // Creates query for the association table
        let icavQuery = icavTable.query();
        icavQuery.predicate = NSPredicate(format: "imageID == %@ and contextID == %@", imageTitle, contextTitle.title!);
        icavQuery.selectFields = ["attributeID", "value"]
        
        // Sends the query
        icavQuery.read(completion: {
            (result, error) in
            if let attributeResults = result?.items {
                for row in attributeResults {
                    let attribute = row["attributeID"] as! String;
                    let attributeValue = row["value"] as! String;
                    
                    // Updates the attributes basied on the return of the query
                    self.updateAttributes(attribute: attribute, value: attributeValue)
                }
            }
        })
    }
    
    // Function to update all allibutes for the selected image
    func updateAttributes(attribute: String, value: String){
        
        // Appends new individual attribute
        attributes.append(attribute)
        
        // Sorts attributes
        attributes = attributes.sorted{$0.localizedCompare($1) == .orderedAscending}
        
        // Appends value to the attribute
        values[attribute] = value;
       
        // Reloads table
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
        // Only 1 section, there will be no dividers
        return 1
    }

    // Returns the number of rows (table cells) in a specified section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attributes.count
    }

    // Asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Creates cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryAttributeTableViewCell", for: indexPath) as! HistoryAttributeTableViewCell
        
        // Grabs the attribute
        let attribute = attributes[indexPath.row]
        
        // Displays the title and the description of the attribute
        cell.attributeTitle.text = attribute
        cell.attributeDescription.text = ""
        cell.attributeAnswer.text = values[attribute]
        
        // Prevents the cell from being selectable
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        // Returns the cell
        return cell
    }
    
    // Prevents the cell from being highlighted when selected
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
