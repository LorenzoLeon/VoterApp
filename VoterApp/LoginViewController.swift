//
//  LoginViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, Announcer {
    
    var maker: Poller?
    var user: User?
    var lastUpdated: Date?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func signIn(_ sender: AnyObject) {
        if username.hasText && password.hasText {
            
            if !username.text!.hasSuffix("@cide.edu") && !username.text!.hasSuffix("@alumnos.cide.edu")
            {
                showAlert(message: NSLocalizedString("Please_Input", comment: "Ask user to input correct email"))
                return
            }
            
            //let email = username.text!
            // let range = email.range(of: "@")
            // let index: Int = email.distance(from: email.startIndex, to: range!.lowerBound)
            // let name = email.substring(to: email.index(email.startIndex, offsetBy: index))
            
            user = User(newUsername: username.text!, newPassword: password.text!, newUserID: nil, newIsVerified: false)
            //TODO: make a loading wait screen
            maker?.pollConnector?.askServer(to: Announcements.SIGNIN, with: user, announceMessageTo: self)
            
            //self.performSegue(withIdentifier: "goToMain", sender: self)
            
        } else {
            showAlert(message: NSLocalizedString("Fill_All", comment: "Ask user to fill all fields"))
        }
    }
    
    @IBAction func enterOnPassword(_ sender: UITextField) {
        signIn(sender)
    }
    
    @IBAction func goBackToLogIn(maker: UIStoryboardSegue) {
    }
    @IBAction func comeFromForget(maker: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationSegue" {
            if let register = segue.destination as? RegisterViewController {
                register.maker =  self.maker
            }
        }
        if segue.identifier == "forgotSegue" {
            if let forgot = segue.destination as? ForgotPasswordViewController, let email = username.text{
                forgot.emailField.text = email
                forgot.maker = self.maker
            }
        }
    }
    
    private func presentDismissAllert(title: String, message: String) {
        let successfullAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
        successfullAlert.addAction(okAction)
        self.present(successfullAlert, animated: true, completion: nil)
    }
    
    func receiveAnnouncement(id: Announcements, announcement data: [String:Any]?) {
        let echo = data?["echo"] as? String
        
        switch id {
        case .SIGNIN:
            presentDismissAllert(title: NSLocalizedString("Success", comment: ""), message: NSLocalizedString("SignInSucc", comment: "You were signed in successfully"))
            print("Login view succesfull login")
        case .ERROR:
        if echo != nil {
            showAlert(message: NSLocalizedString(echo!, comment: ""))
        } else {
            showAlert(message: NSLocalizedString("SomeWrong", comment: "Something went Wrong"), title: NSLocalizedString("UnableToSignIn", comment: "We could not sign you in."))
        }
        case .REQUESTMALFORMED:
            showAlert(message: NSLocalizedString("Fill_All", comment: "Ask user to fill all fields"))
        case .NETWORKINGERROR:
            showAlert(message: NSLocalizedString("UnknownNetError", comment: "Unknown Network Problem; please check your connection status"), title: NSLocalizedString("SomeWrong", comment: "Something went Wrong"))
        case .CHECKSTATUS:
            presentDismissAllert(title: NSLocalizedString("HoldEm", comment: ""), message: NSLocalizedString("AlreadySignedIn", comment: "You were already signed in"))
        default:
            break
        }
        
        
    }
    
    func showAlert(message: String, title: String = NSLocalizedString("Alert", comment: "Alert")) {
        let cancellationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
}
