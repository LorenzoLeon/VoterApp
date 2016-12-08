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
    var myPollsCount : Int?
    var votedPolls : [Poll]?
    var votedPollsCount: Int?
    var openPolls : [Poll]?
    var openPollsCount : Int?
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
    var allPollsCount: Int?
    
    
    
    func remakeTable() {
        myPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return poll.isMine()
        }
        myPollsCount = myPolls?.count
        votedPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return !poll.isMine() && poll.hasVoted
        }
        votedPollsCount = votedPolls?.count
        openPolls = pollMaker?.polls.filter { (poll: Poll) -> Bool in
            return !poll.isMine() && !poll.hasVoted
        }
        openPollsCount = openPolls?.count
        var num = 0
        for list in allPolls {
            num += list!.count
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
            array += [NSLocalizedString("MyPolls", comment: "My Polls")]
        }
        if votedPolls != nil && votedPolls!.count > 0 {
            array += [NSLocalizedString("AnsweredPolls", comment: "Polls I've answered")]
        }
        if openPolls != nil && openPolls!.count > 0 {
            array += [NSLocalizedString("UnansweredPolls", comment: "Unanswered Polls")]
        }
        return array
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let poll = allPolls[indexPath.section]?[indexPath.row] {
            if poll.hasVoted {
                performSegue(withIdentifier: "showResults", sender: poll)
            } else {
                if poll.answerCount() > 2 {
                    performSegue(withIdentifier: "showVoteMore", sender: poll)
                } else {
                    performSegue(withIdentifier: "showVote2", sender: poll)
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell =  UITableViewCell()
        if let poll = allPolls[indexPath.section]?[indexPath.row] {
            cell = tableView.dequeueReusableCell(withIdentifier: poll.pollID , for: indexPath)
            
            return cell
        }
        
        //something wrong happened
        remakeTable()


        return cell
    }
    

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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        switch segue.identifier! {
        case "showResults":
            if let results = segue.destination as? PollResultsViewController {
                results.poll = sender as? Poll
            }
         case   "showVoteMore":
            if let results = segue.destination as? VoteMoreOptionsViewController {
                results.poll = sender as? Poll
            }
         case   "showVote2":
            if let results = segue.destination as? VoteForTwoViewController {
                results.poll = sender as? Poll
            }
        default:
            return
        }
        
    }
    

}
