//
//  MakeAPollViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/28/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class MakeAPollViewController: UIViewController, Announcer{
    
    var lastUpdated: Date?
    
    var maker: Poller?
    
    @IBOutlet weak var pollNameTextField: UITextView!
    
    @IBAction func submitNewPoll(_ sender: UIButton) {
        //check for errors input fields
        //and create poll
        if pollIsViable() {
            
            //fake poll
            let nPoll = Poll(newPollID: "", newCreator: maker?.user!, newQuestion: "", newAnswers: [String](), canChange: false, newCreationDate: Date(), newHasVoted: false, newVote: [[Int]](), newUserID: "", newIsOpen: true, newVoters: nil, newType: .BORDA)
            
            
            maker?.pollConnector?.askServer(to: .CREATE, with: nPoll, announceMessageTo: self)
            
        } else {
            presentModalView(textForAlert: NSLocalizedString("PollIncorrect", comment: "Poll inputs are incorrect"), title: NSLocalizedString("BadPoll", comment: "Bad Poll fields"))
        }
    }
    
    private func pollIsViable() -> Bool {
        var check = false
        if pollNameTextField.hasText {
            if ( pollNameTextField.text!.characters.count > 255) {
                check = false
            } else {
                check = true
            }
        }
        
        
        return check
    }
    
    
    func receiveAnnouncement(id: Announcements, announcement: Any) {
        var responseString = ""
        if let data = announcement as? Data {
            if let tempResponse = String(data: data, encoding: .utf8) {
                responseString = tempResponse
            }
        }
        
        var message = responseString
        var title = NSLocalizedString("SomeWrong", comment: "Something went Wrong")
        
        switch id {
            
        case .CREATE:
            message = NSLocalizedString("SignInSucc", comment: "You were signed in successfully")
            title = NSLocalizedString("Success", comment: "")
        case .NETWORKINGERROR:
            message = NSLocalizedString("SignInSucc", comment: "You were signed in successfully")
            title = NSLocalizedString("Success", comment: "")
        default:
            break
        }
        
        presentModalView(textForAlert: message, title: title)
    }
    
    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
}
