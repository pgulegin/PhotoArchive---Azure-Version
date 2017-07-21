//
//  CameraTagTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 4/25/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class CameraTagTableViewController: UITableViewController {

    // Array of strings with all of the Context Titles from the database
    var contexts = global.shared.dbContexts
    
    // Array of string with all of the Context Descriptions from the database
    var contextsDetails = [String]()
    
    // Dictionary for Contexts with the String as the first letter (ignore case) and the int as how many times it occurs
    var contextsSections = [String:Int]()
    
    // Array of strongs with the sorted keys from the dictionary above
    var contextsSectionsSortedKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // This next function will alphabetize the context for the user
        // Cycle through the global context array
        for i in 0..<contexts.count {
            
            // Grab the first letter of every context
            let sectionLetter = String(contexts[i].id[contexts[i].id.startIndex]).uppercased()
            
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
        contexts = contexts.sorted{$0.id.localizedCompare($1.id) == .orderedAscending}
        
        // Sorts keys into alphabetical order
        contextsSectionsSortedKeys = Array(contextsSections.keys).sorted(by: <)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    // Total number of sections
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contextsSections.count
    }
    
    // Total number of rows for every section
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

    // Asks the data source for a cell to insert in a particular location of the table view
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CameraTagTableViewCell", for: indexPath) as! CameraTagTableViewCell
        
        // Selects the correct context due to having multiple sections
        var count = 0
        count = count + indexPath.row
        
        for i in 0..<indexPath.section {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
        
        // Configures the cell text and description
        cell.title.text = contexts[count].id
        cell.titledescription.text = contexts[count].descriptor
        
        // Returns the appropriate cell
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Creates a new segue destination to send data
        let vc = segue.destination as! CameraAttributeTableViewController
        
        // Selects the correct context due to having multiple sections
        let indexPath = tableView.indexPathForSelectedRow
        
        var count = 0
        count = count + (indexPath?.row)!
        
        for i in 0..<(indexPath?.section)! {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
    
        // Passes the data to the next view controller
        vc.contextTitle.title = contexts[count].id
    }
}
