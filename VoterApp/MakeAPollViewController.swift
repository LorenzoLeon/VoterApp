//
//  MakeAPollViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/28/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class MakeAPollViewController: UIViewController, UITextFieldDelegate{
    
    var maker: Poller?
    
    
    @IBOutlet weak var modifiable: UISwitch!
    
    @IBOutlet weak var pollNameTextField: UITextView!
    
    @IBOutlet weak var anonymous: UISwitch!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var charactersLeft: UILabel!
    
    var start = false
    
    override func viewDidAppear(_ animated: Bool) {
        start = true
    }
    
    var poll = Poll()
    
    @IBAction func next(_ sender: UIButton) {
        if pollNameIsViable() {
            performSegue(withIdentifier: "checkOptionsSegue", sender: self)
        } else {
            presentModalView(textForAlert: "Your Poll Name is too long!")
        }
    }
    

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if start {
            textField.text = ""
            start = false
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let count = textField.text?.characters.count {
            DispatchQueue.main.async{ [unowned self] in
                if count <= 255 {
                    
                    self.charactersLeft.text = "\(count) characters left"
                    self.charactersLeft.textColor = .black
                    self.nextButton.isEnabled = true
                } else {
                    self.charactersLeft.text = "-\(count) characters over"
                    self.charactersLeft.textColor = .red
                    self.nextButton.isEnabled = false
                }
            }
        }
    }
    
    private func pollNameIsViable() -> Bool {
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
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "checkOptionsSegue" {
            let dest = segue.destination as! ChooseOptionsViewController
            dest.maker = self.maker
            poll.name = pollNameTextField.text
            poll.isAnonymous = anonymous.isOn
            poll.modifiable = modifiable.isOn
            dest.poll = poll
        }
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
