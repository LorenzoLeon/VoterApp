//
//  PollListViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/28/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class PollListViewController: UIViewController, PollListener/*, UITableViewDelegate, UITableViewDataSource*/ {
    
    var pollMaker: Poller?

    @IBOutlet weak var pollTable1: UITableView!
    

    func pollsHaveChanged() {
        //redraw table view
    }
    
}
