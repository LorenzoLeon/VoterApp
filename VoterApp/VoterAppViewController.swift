//
//  VoterAppViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

protocol GodMaker: class  {
    func getPHPConnector() -> PollPHPConnector?
    var user: User? {
        get
        set
    }
}

class VoterAppViewController: UIViewController, GodMaker {
    
    @IBOutlet weak var logOutButton: UIButton!
    
    var pollStore: PollContainerModel?
    
    
    var isLoggedIn: Bool? {
        return pollStore?.user != nil
    }
    
    var pollConnector: PollPHPConnector?

    var user: User? {
        get {
            return pollStore?.user
        }
        set {
            if newValue != nil {
                pollStore = PollContainerModel(newUser: newValue)
                pollConnector = PollPHPConnector()
            } else {
  
                //display error.
                pollConnector?.signOut()
                pollConnector = nil
                pollStore = nil
            }
        }
    }
    
    var validated: Bool? {
        get {
            return user?.isVerified()
        }
        set {
            user?.setVerified(ver: newValue)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkLogIn()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let loginview = segue.destination as? LoginViewController {
        loginview.setMaker(maker: self)
        }
        if let pollList = segue.destination as? PollListViewController {
            pollList.pollStore = pollStore
        }
    }
    
    
    
    @IBAction func logOut(_ sender: UIButton) {
        //save message, display error
        if isLoggedIn != nil {
            user = nil
            checkLogIn()
        } else {
            performSegue(withIdentifier: "LogIn", sender: self)
        }
    }
    
    private func checkLogIn() {
        if isLoggedIn == false {
            logOutButton.setTitle("Log In", for: UIControlState.normal)
        } else {
            logOutButton.setTitle("Log Out", for: UIControlState.normal)
        }
    }
    
    @IBAction func goToMainView(maker: UIStoryboardSegue) {
        
    }
    
    func getPHPConnector() -> PollPHPConnector? {
        return pollConnector
    }
    
}
