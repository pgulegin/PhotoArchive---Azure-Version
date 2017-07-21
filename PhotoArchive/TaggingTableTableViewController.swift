//
//  TaggingTableTableViewController.swift
//  PhotoArchive
//
//  Created by Phillip Gulegin on 2/21/17.
//  Copyright © 2017 Phillip Gulegin. All rights reserved.
//

import UIKit

class TaggingTableTableViewController: UITableViewController {

    var contexts = global.shared.dbContexts     // Context titles from the database
    var contextsDetails = [String]()            // Context descriptions from the database
    var contextsSections = [String:Int]()       // Dictionary for Contexts with the String as the first letter (ignore case) and the int as how many times it occurs
    var contextsSectionsSortedKeys = [String]() // Sorted keys for the dictionary
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Splits everything into sections
        for i in 0..<contexts.count {
            
            let sectionLetter = String(contexts[i].id[contexts[i].id.startIndex]).uppercased()
            
            if (contextsSections[sectionLetter] != nil) {
                contextsSections[sectionLetter] = contextsSections[sectionLetter]! + 1
            }
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

    // Confirgures the cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cell to be prepared
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaggingTableTableViewCell", for: indexPath) as! TaggingTableTableViewCell
        
        // Figures out which context is going to be called
        var count = 0
        count = count + indexPath.row
        
        for i in 0..<indexPath.section {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
        
        // Configures the cell
        cell.title.text = contexts[count].id
        cell.titledescription.text = contexts[count].descriptor
        
        // Returns the cell
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Sets the next view controller
        let vc = segue.destination as! AttributeTableTableViewController
        
        let indexPath = tableView.indexPathForSelectedRow
        
        var count = 0
        count = count + (indexPath?.row)!
        
        for i in 0..<(indexPath?.section)! {
            count = count + contextsSections[contextsSectionsSortedKeys[i]]!
        }
        
        // Passes in the appropraite context
        vc.contextTitle.title = contexts[count].id
    }
 

}
