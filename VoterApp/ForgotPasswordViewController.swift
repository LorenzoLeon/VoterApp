//
//  ForgotPasswordViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/26/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, Announcer {
    
    var lastUpdated: Date?
    
    @IBOutlet weak var emailField: UITextField!
    
    var maker: Poller?
    
    // TODO: set connection
    @IBAction func sendPass(_ sender: AnyObject) {
        if emailField.hasText {
            
            if !emailField.text!.hasSuffix("@cide.edu") && !emailField.text!.hasSuffix("@alumnos.cide.edu")
            {
                presentModalView(textForAlert: NSLocalizedString("Please_Input", comment: ""))
                return
            }
            maker!.pollConnector!.askServer(to: .FORGOT, with: emailField.text, announceMessageTo: self)
            
        }
    }
    
    
    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: Any) {
        //TODO: 
        self.performSegue(withIdentifier: "exitToLogin", sender: self)
    }
    
    func receiveAnnouncement(id: Announcements, announcement data: [String:Any]?) {
        
        switch id {
        case .FORGOT:
            let successfullAlert = UIAlertController(title: NSLocalizedString("Success", comment: "Success!"), message: NSLocalizedString("CheckEmail", comment: "Check your email for the password reset link"), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { [unowned self]_ in
                self.goBack(self)
            }
            successfullAlert.addAction(okAction)
            self.present(successfullAlert, animated: true, completion: nil)
            //self.performSegue(withIdentifier: "exitToLogin", sender: self)
            
        case .NETWORKINGERROR:
            presentModalView(textForAlert: NSLocalizedString("SomeWrong", comment: "Something Went Wrong"), title: NSLocalizedString("NetError", comment: "Network Error"))
        case .ERROR:
            presentModalView(textForAlert: NSLocalizedString("WrongWithEmail", comment: "Something Went Wrong with email service"), title: NSLocalizedString("SomeWrong", comment: "Something Went Wrong"))
        case .REQUESTMALFORMED:
            presentModalView(textForAlert: NSLocalizedString("NoSuchAccount", comment: "There is no such account with that email"), title: NSLocalizedString("Sorry", comment: ""))
        case .CHECKSTATUS:
            let successfullAlert = UIAlertController(title: NSLocalizedString("HoldEm", comment: ""), message: NSLocalizedString("AlreadySignedIn", comment: "You were already signed in"), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
            successfullAlert.addAction(okAction)
            print("Login view already login")
            self.present(successfullAlert, animated: true, completion: nil)
        default:
            break
        }
    }
    
}
