//
//  ForgotPasswordViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/26/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // TODO: set connection
    @IBAction func sendPass(_ sender: AnyObject) {
        
        
    self.performSegue(withIdentifier: "exitToLogin", sender: self)
       
    }
    
    @IBAction func emailEnter(_ sender: AnyObject) {
        sendPass(sender)
    }
    
    
    @IBAction func goBack(_ sender: UIBarButtonItem) {
        //send alert
        self.performSegue(withIdentifier: "exitToLogin", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let dest = segue.destination as? LoginViewController {
//            dest.username.text = emailField.text
//        }
    }

}
