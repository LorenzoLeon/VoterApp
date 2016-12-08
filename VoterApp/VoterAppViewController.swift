//
//  VoterAppViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

protocol Announcer: class {
    var lastUpdated : Date? {
        get
    }
    func receiveAnnouncement(id: Announcements, announcement: Any)
}


protocol Poller: Announcer {
    var user: String? {
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

class VoterAppViewController: UIViewController, Poller {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    
    var polls = [Poll]()
    
    var lastUpdated : Date?
    
    var listeners = [PollListener]()
    
    var pollConnector: PollPHPConnector?
    var color: UIColor?
    
    /*var user: User? {
     didSet {
     polls = [Poll]()
     notifyListeners()
     if user == nil {
     //sign out from server
     pollConnector?.signOut(announceMessageTo: self)
     } else {
     //Sign in to server
     pollConnector?.signIn(with: user!, announceMessageTo: self)
     }
     }
     }*/
    
    
    var user: String? {
        didSet {
            polls = [Poll]()
            notifyListeners()
        }
    }
    
    private var validated = false
    
    
    var isLoggedIn: Bool {
        return user != nil
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
                if let pollListView = segue.destination as? PollTableViewController {
                    pollListView.pollMaker = self
                    listeners.append(pollListView)
                }
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
    
    @IBAction func goToMainView(maker: UIStoryboardSegue) {
    }
    
    private func checkLogIn() {
        if isLoggedIn == false {
            logOutButton.backgroundColor? = color != nil ? color! : .blue
            logOutButton.setTitle("Log In", for: UIControlState.normal)
            editProfileButton.isEnabled = false
        } else {
            color = logOutButton.backgroundColor!
            logOutButton.backgroundColor? = .red
            logOutButton.setTitle("Log Out", for: UIControlState.normal)
            setTouchable()
            editProfileButton.isEnabled = true
        }
    }
    
    private func setTouchable() {
        //if not validated forbid poll checking and stuff.
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
    
    func presentModalViewMessage(with message: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    private func signIn(with responseString: String) {
        if responseString.contains("successful") || responseString.contains("already"){
            
            let rangeOfUsername = Range(uncheckedBounds: (lower: responseString.range(of: "*")!.upperBound, upper: responseString.range(of: "#")!.lowerBound))
            user = responseString.substring(with: rangeOfUsername)
            
            if responseString.contains("validated") {
                validated = true
                pollConnector?.askServer(to: .UPDATE)
            }
        }
    }
    
    private func signOut(with responseString: String) {
        var message = responseString
        var title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
        
        if responseString.contains("successful") {
            message =  NSLocalizedString("Goodbye", comment: "Goodbye! Sign in to check your polls :D")
            title =  NSLocalizedString("LoggedOut", comment: "You've been logged out")
            user = nil
        } else {
            title = NSLocalizedString("Sorry", comment: "")
            message = NSLocalizedString("LogOutProblem", comment: "")
            //do not
            pollConnector?.deleteCookies()
        }
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        presentModalViewMessage(with: message, title: title)
    }
    
    private func delete(poll responseString: String) {
        if responseString.contains("successfully") {
            //check poll id?
            presentModalViewMessage(with: "caca", title: "cece")
        }
    }
    
    
    func receiveAnnouncement(id: Announcements, announcement: Any) {
        //default is an Alert message with the echo response (or error message) as main text.
        var responseString = ""
        if let da = announcement as? Data {
            if let r = String(data: da, encoding: .utf8) {
                responseString = r
            }
        }
        
        var message = responseString
        var title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
        
        switch id {
            
        case .SIGNIN:
            signIn(with: responseString)
            
            
        case .SIGNOUT:
            signOut(with: responseString)
            
            
        case .NETWORKINGERROR: //there has been an network error in the app or a bad connection with the server
            
            title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
            message =  NSLocalizedString("UnknownNetError", comment: "Unknown Network Problem; please check your connection status")
            presentModalViewMessage(with: message, title: title)
            
        case .DELETE:
            delete(poll: responseString)
            
        case .VOTE:
            do {
                let jsonVote = try parseToJSON(with: announcement as! Data) as! [String: [[Int]]]
                for (pollID, votes) in jsonVote {
                    let first = polls.first { poll in
                        return pollID == poll.pollID
                    }
                    if (first?.setVotes(to: votes)) != nil {
                        message = NSLocalizedString("VoteRegistered", comment: "Your vote was successfully registered")
                        title = NSLocalizedString("Hurray", comment: "Hurray!")
                        notifyListeners()
                    }
                }
            } catch {
                title = NSLocalizedString("VoteNotRegisterded", comment: "Your vote was not registered.")
            }
            
        case .UPDATE:
            do {
                let jsonUpdate = try parseToJSON(with: announcement as! Data)
                
                if let result = jsonUpdate as? [String: Any] {
                    let poll = Poll(jsonResults: result, nuserID: user!)
                    updatePollList(with: poll)
                } else if let listOfPolls = jsonUpdate as? [[String: Any]] {
                    lastUpdated = Date()
                    for result in listOfPolls {
                        let poll = Poll(jsonResults: result, nuserID: user!)
                        updatePollList(with: poll)
                    }
                }
            } catch {
                //error while trying to update poll with id
                //No json data in message => no polls to update or all polls up to date
                if responseString.contains("up to date") {
                    lastUpdated = Date()
                    message = NSLocalizedString("AlreadyUpdated", comment: "All polls are up to date")
                    title = NSLocalizedString("Nothing", comment: "Nothing to do")
                } else {
                    message = NSLocalizedString("NoLongerExists", comment: "The poll you requested no longer exists or was deleted")
                }
            }
            notifyListeners()
            //----------------------------------------------------------------------------------------
        default:
            break
        }
        
        if responseString.contains("Please") {//please sign in error message
            //not signed in
            user = nil
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            title = NSLocalizedString("You're not signed in!", comment: "")
            message = NSLocalizedString("NotSignedIn", comment: "You're trying to check something out that requires you to be logged in! Please sign in before you continue")
            
            presentModalViewMessage(with: message, title: title)
            
        } else if responseString.contains("already"){//can get it when loggin in or registering.
            signIn(with: responseString)
        }
        
        checkLogIn()
        setTouchable()
    }
    
    private func updatePollList(with poll: Poll) {
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
    private func parseToJSON(with data: Data) throws -> Any {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
    }
    
}
