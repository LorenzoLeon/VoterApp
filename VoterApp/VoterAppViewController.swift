//
//  VoterAppViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

protocol GodMaker: class  {
    func getPHPConnector() -> PollPHPConnector?
    var user: User? {
        get
        set
    }
}

class VoterAppViewController: UIViewController, GodMaker {

    
    var isLoggedIn: Bool? = false
    var pollConnector: PollPHPConnector?
    var pollStore: PollContainerModel?
    var user: User? {
        get {
            return pollStore?.user
        }
        set {
            if newValue != nil {
            pollStore = PollContainerModel(newUser: newValue!)
            pollConnector = PollPHPConnector(newPollStore: pollStore!)
            } else {
                pollConnector = nil
                pollStore = nil
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isLoggedIn == nil || isLoggedIn == false {
        performSegue(withIdentifier: "LogIn", sender: self)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let loginview = segue.destination as? LoginViewController
        loginview?.setMaker(maker: self)
    }

    func getPHPConnector() -> PollPHPConnector? {
        return pollConnector
    }

}
