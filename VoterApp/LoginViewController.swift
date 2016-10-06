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
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signIn(_ sender: AnyObject) {
        if username.hasText && password.hasText {
            
            if !username.text!.hasSuffix("@cide.edu") && !username.text!.hasSuffix("@alumnos.cide.edu")
            {
                showAlert(message: "Please input a valid CIDE address")
                return
            }
            
            let email = username.text!
            let range = email.range(of: "@")
            let index: Int = email.distance(from: email.startIndex, to: range!.lowerBound)
            let name = email.substring(to: email.index(email.startIndex, offsetBy: index))
            
            let user = User(newUsername: name, newPassword: password.text!, newUserID: nil, newIsVerified: false)
            maker!.user = user
            self.performSegue(withIdentifier: "goToMain", sender: self)
            
        } else {
            showAlert(message: "Please Fill in all the fields")
        }
    }
    
    func showAlert(message: String) {
        let cancellationAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
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
            }
        }
    }
    
    @IBAction func goBackToLogIn(maker: UIStoryboardSegue) {
    }
    @IBAction func comeFromForget(maker: UIStoryboardSegue) {
    }
}
