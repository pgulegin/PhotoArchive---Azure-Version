//
//  HistoryTagTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/11/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class HistoryTagTableViewController: UITableViewController {
    
    var imageTitle: String!                     // Title of the selected image
    var contexts = ["Loading..."];              // Temporary value for the contexts
    var contextsDetails = [String]()            // Array of string with all of the Context Descriptions from the database
    var contextsSections = [String:Int]()       // Dictionary for Contexts with the first letter of every context
    var contextsSectionsSortedKeys = [String]()     // Array of strongs with the sorted keys from the dictionary above

    // Called after the controller's view is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This next function will alphabetize the context for the user
        // Cycle through the global context array
        for i in 0..<contexts.count {
            
            // Grab the first letter of every context
            let sectionLetter = String(contexts[i][contexts[i].startIndex]).uppercased()
            
            // If the letter does not exist, create a new counter for it
            if (contextsSections[sectionLetter] != nil) {
                contextsSections[sectionLetter] = contextsSections[sectionLetter]! + 1
            }
            // Increment the counter in the dictionary
            else {
                contextsSections[sectionLetter] = 1;
            }
        }
        
        // Sorts contexts into alphabetical order
        contexts = contexts.sorted{$0.localizedCompare($1) == .orderedAscending}
        
        // Sorts keys into alphabetical order
        contextsSectionsSortedKeys = Array(contextsSections.keys).sorted(by: <)
        
        // Reloads the data in the table
        self.tableView.reloadData()
    }

    // Sent to the view controller when the app receives a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    // Total number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contextsSections.count
    }

    // Total number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contextsSections[contextsSectionsSortedKeys[section]]!
    }
    
    // Title for every section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contextsSectionsSortedKeys[section]
    }
    
    // Index on the right for every section title
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contextsSectionsSortedKeys
    }

    // Confirgures the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryTagTableViewCell", for: indexPath) as! HistoryTagTableViewCell
        
        // Finds which context is the one that needs to be printed
        var count = 0
        count = count + indexPath.row
        
        for i in 0..<indexPath.section {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
        
        // Configure the cell...
        cell.title.text = contexts[count]
        cell.titledescription.text = ""
        
        return cell
    }
    
    // Prepares the next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Creates a new segue destination to send data
        let vc = segue.destination as! HistoryAttributeTableViewController
        
        // Selects the correct object due to having multiple sections
        let indexPath = tableView.indexPathForSelectedRow
        
        var count = 0
        count = count + (indexPath?.row)!
        
        for i in 0..<(indexPath?.section)! {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
        
        // Passes the data to the next view controller
        vc.contextTitle.title = contexts[count]
        vc.imageTitle = imageTitle;
    }
}
