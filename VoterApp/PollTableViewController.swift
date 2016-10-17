//
//  PollTableViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 10/16/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class PollTableViewController: UITableViewController,PollListener/*, UITableViewDelegate, UITableViewDataSource*/ {
    
    var pollMaker: Poller? {
        didSet {
            if pollMaker != nil {
                remakeTable()
            }
        }
    }
    
    var myPolls : [Poll]?
    var votedPolls : [Poll]?
    var openPolls : [Poll]?
    var allPolls: [[Poll]?] {
        get  {
            var array = [[Poll]?]()
            if myPolls != nil && myPolls!.count > 0 {
                array += [myPolls]
            }
            if votedPolls != nil && votedPolls!.count > 0 {
                array += [votedPolls]
            }
            if openPolls != nil && openPolls!.count > 0 {
                array += [openPolls]
            }
            return array
        }
    }
    
    
    
    func remakeTable() {
        myPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return poll.isMine()
        }
        votedPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return !poll.isMine() && poll.hasVoted
        }
        openPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return !poll.isMine() && !poll.hasVoted
        }
    }
    
    func pollsHaveChanged() {
        remakeTable()
        self.tableView!.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return allPolls.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = allPolls[section]?.count {
            return num
        }
        return 0
    }
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var array = [String]()
        if myPolls != nil && myPolls!.count > 0 {
            array += ["My Polls"]
        }
        if votedPolls != nil && votedPolls!.count > 0 {
            array += ["Polls I've answered"]
        }
        if openPolls != nil && openPolls!.count > 0 {
            array += ["Unanswered Polls"]
        }
        return array
    }
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
