//
//  LoginViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var maker: GodMaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registrationSegue" {
            if let register = segue.destination as? RegisterViewController {
                register.setMaker(maker: self.maker)
            }
        }
    }
    func setMaker(maker: GodMaker?){
        self.maker = maker
    }

}
