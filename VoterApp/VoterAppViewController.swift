//
//  VoterAppViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

protocol Poller: class {
    var user: User? {
        get
        set
    }
    var polls: [Poll] {
        get
        set
    }
    var listeners: [PollListener] {
        get
    }
    var pollConnector: PollPHPConnector? {
        get
    }
    func failAlert (with: String)
    func notifyListeners()
}

protocol PollListener: class {
    func pollsHaveChanged()
}

class VoterAppViewController: UIViewController, Poller {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    var polls = [Poll]()
    
    var listeners = [PollListener]()
    
    var pollConnector: PollPHPConnector?

    var user: User? {
        didSet {
            polls = [Poll]()
            if user == nil {
                pollConnector?.signOut()
            } else {
                pollConnector?.signIn()
            }
        }
    }
    
    var isLoggedIn: Bool {
        return user != nil
    }
    
    var validated: Bool? {
        get {
            return user?.isVerified
        }
        set {
            user?.isVerified = newValue
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLogIn()
    }
    
    override func viewDidLoad() {
        pollConnector = PollPHPConnector(storer: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "ShowPollTableView":
                let pollListView = segue.destination as? PollListViewController
                pollListView?.pollMaker = self
            case "LogIn":
                let loginview = segue.destination as? LoginViewController
                loginview?.maker = self
            case "MakeAPoll":
                let makeView = segue.destination as? MakeAPollViewController
                makeView?.maker = self
            case "ContactVoterApp":
                let contact = segue.destination as? ContactViewController
                contact?.maker = self
            default:
                break
            }
        }
    }
    
    
    @IBAction func makeANewPoll(_ sender: UIButton) {
        performSegue(withIdentifier: "MakeAPoll", sender: self)
    }
    
    @IBAction func checkMyPolls(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowPollTableView", sender: self)
    }
    
    @IBAction func contactVoter(_ sender: UIButton) {
        performSegue(withIdentifier: "ContactVoterApp", sender: self)
    }
    
    @IBAction func logOut(_ sender: UIButton) {
        if isLoggedIn == false {
            performSegue(withIdentifier: "LogIn", sender: self)
        } else {
            user = nil
        }
    }
    
    private func checkLogIn() {
        if isLoggedIn == false {
            logOutButton.setTitle("Log In", for: UIControlState.normal)
        } else {
            logOutButton.setTitle("Log Out", for: UIControlState.normal)
            if let veryfied =  user?.isVerified() {
                setTouchable(to: veryfied)
            }
        }
    }
    
    @IBAction func goToMainView(maker: UIStoryboardSegue) {
    }
    
    private func setTouchable(to allow: Bool) {
        
    }
    
    func notifyListeners() {
        for listener in listeners {
            listener.pollsHaveChanged()
        }
    }
    
    func failAlert(with message: String) {
        let cancellationAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
}
