//
//  LoginViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var maker: Poller?
    var user: User?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!

    
    @IBAction func signIn(_ sender: AnyObject) {
        if username.hasText && password.hasText {
            
            if !username.text!.hasSuffix("@cide.edu") && !username.text!.hasSuffix("@alumnos.cide.edu")
            {
                showAlert(message: NSLocalizedString("Please_Input", comment: "Ask user to input correct email"))
                return
            }
            
            let email = username.text!
           // let range = email.range(of: "@")
           // let index: Int = email.distance(from: email.startIndex, to: range!.lowerBound)
           // let name = email.substring(to: email.index(email.startIndex, offsetBy: index))
            
            user = User(newUsername: email, newPassword: password.text!, newUserID: nil, newIsVerified: false)
            //TODO: make a loading wait screen
            self.performSegue(withIdentifier: "goToMain", sender: self)
            
        } else {
            showAlert(message: NSLocalizedString("Fill_All", comment: "Ask user to fill all fields"))
        }
    }
    
    func showAlert(message: String, title: String = NSLocalizedString("Alert", comment: "Alert")) {
        let cancellationAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func enterOnPassword(_ sender: UITextField) {
        signIn(sender)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationSegue" {
            if let register = segue.destination as? RegisterViewController {
                register.maker =  self.maker
            }
        }
        if segue.identifier == "Forgot you Password" {
            if let forgot = segue.destination as? ForgotPasswordViewController, let email = username.text{
                forgot.emailField.text = email
                forgot.maker = self.maker
            }
        }
        if segue.identifier == "goToMain" {
            maker!.user = user
        }
    }
    
    @IBAction func goBackToLogIn(maker: UIStoryboardSegue) {
    }
    @IBAction func comeFromForget(maker: UIStoryboardSegue) {
    }
}
