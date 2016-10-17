//
//  ForgotPasswordViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/26/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController, Announcer {
    
    @IBOutlet weak var emailField: UITextField!
    
    var maker: Poller?
    
    // TODO: set connection
    @IBAction func sendPass(_ sender: AnyObject) {
        if emailField.hasText {
            
            if !emailField.text!.hasSuffix("@cide.edu") && !emailField.text!.hasSuffix("@alumnos.cide.edu")
            {
                showAlert(message: "Please input a valid CIDE address")
                return
            }
            
            maker!.pollConnector!.forgotPassword(email: emailField.text!, delegate: self)
            
            
        }
    }
    
    
    func showAlert(message: String) {
        let cancellationAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        //send alert
        self.performSegue(withIdentifier: "exitToLogin", sender: self)
    }
    
    func receiveAnnouncement(id: String, announcement: Any) {
        switch id {
        case "Password sent":
            //check received message
            self.performSegue(withIdentifier: "exitToLogin", sender: self)
        default:
            showAlert(message: announcement as! String)
        }
    }
    
}
