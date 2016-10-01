//
//  PollListViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/28/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class PollListViewController: UIViewController/*, UITableViewDelegate, UITableViewDataSource*/ {
    
    var pollStore: PollContainerModel?

    @IBOutlet weak var pollTable1: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
