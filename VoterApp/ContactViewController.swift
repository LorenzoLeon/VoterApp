//
//  ContactViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/28/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    var maker: Poller?
    
    @IBOutlet weak var senderTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendComment(_ sender: AnyObject) {
    }

}
