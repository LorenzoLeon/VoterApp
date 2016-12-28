//
//  VoterAppViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class VoterAppViewController: UIViewController, Poller {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var editProfileButton: UIBarButtonItem!
    
    var pollList: PollList?
    
    var lastUpdated : Date? {
        get {
            return pollList?.getLastUpdatedPoll()?.date
        }
    }
    
    var listeners = [PollListener]()
    
    var pollConnector: PollPHPConnector?
    var color: UIColor?
    
    /*
     * set to NIL to log out completelly and destroy all session info
     */
    var user: String? {
        didSet {
            if user == nil {
                userID = nil
                isValidated = false
                //TODO: destroy session info
                //TODO: SEND MESSAGE TO USER ABOUT LOGGING OUT
                
            }
            checkLogIn()
            pollList?.reset()
            notifyListeners()
        }
    }
    
    var userID: Int?
    
    private var isValidated = false
    
    var isLoggedIn: Bool {
        return user != nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //load old sign in data?
        checkLogIn()
    }
    
    override func viewDidLoad() {
        pollConnector = PollPHPConnector(announcer: self)
        pollList = PollList(newPoller: self)
        pollConnector?.askServer(to: .CHECKSTATUS)
        if user != nil {
            fullUpdate()
        }
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
        DispatchQueue.main.async{ [unowned self] in
            if self.isLoggedIn == false {
                self.logOutButton.backgroundColor? = self.color != nil ? self.color! : .blue
                self.logOutButton.setTitle("Log In", for: UIControlState.normal)
                self.editProfileButton.isEnabled = false
            } else {
                self.color = self.logOutButton.backgroundColor!
                self.logOutButton.backgroundColor? = .red
                self.logOutButton.setTitle("Log Out", for: UIControlState.normal)
                self.setTouchable()
                self.editProfileButton.isEnabled = true
            }
        }
    }
    
    private func setTouchable() {
        //if not validated forbid poll checking and stuff.
    }
    
    func notifyListeners() {
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
    
    private func signIn(with jsonLogin: [String: Any]) {
        if (jsonLogin["status"] as! Int != 0) {
            user = jsonLogin["user"] as? String
            userID = jsonLogin["id"] as? Int
            if let val = jsonLogin["validated"] as? Int  {
                isValidated = val != 0
            } else {
                isValidated = false
            }
        } else {
            user = nil
            //nothing
        }
        
        
    }
    
    private func signOut(with jsonLogOut: [String: Any]) {
        var message = jsonLogOut["echo"] as! String
        var title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
        
        if jsonLogOut["status"] as! Int != 0 {
            message =  NSLocalizedString("Goodbye", comment: "Goodbye! Sign in to check your polls :D")
            title =  NSLocalizedString("LoggedOut", comment: "You've been logged out")
            user = nil
        } else {
            message = NSLocalizedString("LogOutProblem", comment: "")
            //do
            pollConnector?.deleteCookies()
        }
        presentModalViewMessage(with: message, title: title)
    }
    //TODO: complete
    
    func update(with data: Any?) -> Bool  {
        var check = true
        if let listOfPolls = data as? [[String:Any]]  {
            let update = Date()
            for result in listOfPolls {
                if !pollList!.updatePollList(with: result, andDate: update) {
                    //something went wrong with json structure
                    check = false
                }
            }
            notifyListeners()
            return check
        } else {
            return false
        }
    }
    
    func fullUpdate() {
        pollConnector?.askServer(to: .UPDATE, extra: lastUpdated) //if there are no polls or all were updated at the same time you get nil in last updated and so you get all available polls for user
    }
    
    func updatePoll(poll: Int) -> Bool {
        if let (_, d) = pollList?.getPoll(poll: poll) {
            pollConnector?.askServer(to: .UPDATE, with: poll, extra: d)
            return true
        }
        return false
        
    }
    
    func receiveAnnouncement(id: Announcements, announcement data: [String:Any]?) {
        //default is an Alert message with the echo response (or error message) as main text.
        
        let echo = data?["echo"]
        var message: String
        var title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
        
        switch id {
        case .SIGNIN:
            signIn(with: data!)
        case .SIGNOUT:
            signOut(with: data!)
        case .NETWORKINGERROR: //there has been an network error in the app or a bad connection with the server
            
            title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
            message =  NSLocalizedString("UnknownNetError", comment: "Unknown Network Problem; please check your connection status")
            presentModalViewMessage(with: message.appending(echo as! String), title: title)
            
        case .DELETE:
            if let id = echo as? Int {
                _ = pollList?.delete(pollID: id)
                notifyListeners()
            }
        case .VOTE: //which is an update
            _ = update(with: echo)
            
        case .UPDATE:
            _ = update(with: echo)
            
        //----------------------------------------------------------------------------------------
        case .CREATE:
            _ = update(with: echo)
            
        case .CHECKSTATUS:
            print("domo")
            if (data?["status"] as! Int != 0) {
                if isLoggedIn {
                    if user != (data!["user"] as! String) {
                        //first Sign OUT!
                        user = nil
                        //THIS SHOULDN'T HAPPEN ANYWAYS
                    }
                } else {
                    userID = (data!["id"] as! Int)
                    isValidated = data!["validated"] as! Int != 0
                    user = data!["user"] as? String
                    
                }
            } else {
                user = nil
                //                self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
                //                title = NSLocalizedString("You're not signed in!", comment: "")
                //                message = NSLocalizedString("NotSignedIn", comment: "You're trying to check something out that requires you to be logged in! Please sign in before you continue")
                //
                //                presentModalViewMessage(with: message, title: title)
            }
        default:
            break
        }
        
        checkLogIn()
        setTouchable()
    }
    
}

