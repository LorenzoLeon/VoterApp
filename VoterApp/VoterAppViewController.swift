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
    func notifyListeners()
}

protocol PollListener: class {
    func pollsHaveChanged()
}

class VoterAppViewController: UIViewController, Poller, Announcer {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    var polls = [Poll]()
    
    var lastUpdated : Date?
    
    var listeners = [PollListener]()
    
    var pollConnector: PollPHPConnector?
    
    var user: User? {
        didSet {
            polls = [Poll]()
            if user == nil {
                pollConnector?.signOut()
            } else {
                pollConnector?.signIn(with: user!)
                pollConnector?.update()
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
        //load old sign in data?
        checkLogIn()
    }
    
    override func viewDidLoad() {
        pollConnector = PollPHPConnector(announcer: self)
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
            if let veryfied =  user?.isVerified {
                setTouchable(to: veryfied)
            }
        }
    }
    
    @IBAction func goToMainView(maker: UIStoryboardSegue) {
    }
    
    private func setTouchable(to allow: Bool) {
        
    }
    
    func notifyListeners() {
        polls.sort { (poll1, poll2) -> Bool in
            if let num1 = compare(date1: poll1.creationDate, date2: poll2.creationDate) {
                return num1
            } else if let num2 = compare(date1: poll1.updateTime, date2: poll2.updateTime){
                return num2
            } else {
                return poll1.pollID < poll2.pollID
            }
        }
        for listener in listeners {
            listener.pollsHaveChanged()
        }
    }
    
    func presentModalViewMessage(with message: String, title: String = "Alert") {
        let cancellationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    func receiveAnnouncement(id: String, announcement: Any) {
        let responseString = String(data: announcement as! Data, encoding: .utf8)
        var showMessage = true
        
        var message = responseString!
        var title = "Something went wrong!"
        
        switch id {
        case "Sign In":
            if responseString!.contains("successfully") {
                if responseString!.contains("validated") {
                    validated = true
                }
                message = "You were signed in successfully"
                title = "Success!"
                
            }
        case "Sign Out":
            if responseString!.contains("successfully") {
                message =  "Goodbye! Sign in to check your polls :D"
                title =  "You've been logged out"
            }
        case "PollDelete":
            if responseString!.contains("successfully") {
                //check poll id?
                message = "Poll was successfully deleted"
                title =  "yay"
            }
        case "Vote":
            do {
                let jsonVote = try parseToJSON(with: announcement as! Data) as! [String: [[Int]]]
                for (pollID, votes) in jsonVote {
                    let first = polls.first { poll in
                        return pollID == poll.pollID
                    }
                    if (first?.setVotes(to: votes)) != nil {
                        message = "Your vote was successfully registered"
                        title = "Hurray!"
                        notifyListeners()
                    }
                }
                
            } catch {
                title = "Your vote was not registered."
            }
        case "Update":
            if self.view.window == nil {
                showMessage = false
            }
            do {
                let jsonUpdate = try parseToJSON(with: announcement as! Data)
                
                if let result = jsonUpdate as? [String: Any] {
                    let poll = Poll(jsonResults: result, nuserID: user!.userID!)
                    updatePollList(with: poll)
                } else if let listOfPolls = jsonUpdate as? [[String: Any]] {
                    for result in listOfPolls {
                        let poll = Poll(jsonResults: result, nuserID: user!.userID!)
                        updatePollList(with: poll)
                    }
                }
                message = "Polls have been updated"
                title = "Yay"
            } catch {
                //error while trying to update poll with id
                //No json data in message => no polls to update or all polls up to date
                if let _ = responseString?.contains("up to date") {
                    message = "All polls are up to date"
                    title = "Nothing to do!"
                } else {
                    message = "The poll you requested no longer exists or was deleted"
                }
            }
            notifyListeners()
        default:
            message =  "Unknown Network Problem; please check your connection status"
        }
        if showMessage {
            presentModalViewMessage(with: message, title: title)
        }
    }
    
    func updatePollList(with poll: Poll) {
        if let index = polls.index(where: { (original: Poll) -> Bool in //if poll exists in list remove? or update
            return original == poll
        }) {
            polls.remove(at: index)
        }
        polls.append(poll)
    }
    
    private func compare(date1: Date, date2: Date) -> Bool? {
        let compare = date1.compare(date2)
        switch compare {
        case .orderedAscending:
            return false
        case .orderedDescending:
            return true
        case .orderedSame:
            return nil
        }
    }
    
    
    //TODO: CHECK
    func parseToJSON(with data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
    }
    
}
