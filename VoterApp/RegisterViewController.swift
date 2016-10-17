//
//  RegisterViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, Announcer {
    
    
    //TODO
    var maker: Poller?
    var lastUpdated: Date?
    
    @IBOutlet weak var genderPicker: UIPickerView!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var passwordRepeat: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var dateofBirth: UIDatePicker!
    
    @IBOutlet var maxView: UIView!
    
    @IBOutlet weak var emailVerificationLabel: UILabel!
    
    private let pickerOptions = [["Male", "Female"], Division.allValues(), (0...20).map {
        if $0 == 0 {
            return "No es estudiante"
        }else if $0 < 9 {
            return String($0) + "º Licenciatura"
        } else if $0 < 13 {
            return String($0 - 8) + "º Maestría"
        } else {
            return String($0 - 12) + "º PhD"
        }}]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        genderPicker.delegate = self
        genderPicker.dataSource = self
        //email.inputDelegate = self
        emailVerificationLabel.isHidden = true
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if email.hasText && password.hasText && passwordRepeat.hasText {
            if password.text! != passwordRepeat.text! {
                presentModalView(textForAlert: "Passwords don't match", title: "Hold your horses!")
                return
            }
            if !email.text!.hasSuffix("@cide.edu") && !email.text!.hasSuffix("@alumnos.cide.edu")
            {
                presentModalView(textForAlert: "Please input a valid CIDE address", title: "Are you from around?")
                return
            }
            let user = email.text!
            let range = user.range(of: "@")
            let index: Int = user.distance(from: user.startIndex, to: range!.lowerBound)
            let username = user.substring(to: user.index(user.startIndex, offsetBy: index))
            let gender: Gender = genderPicker.selectedRow(inComponent: 0) == 0 ? Gender.Male : Gender.Female
            let division = Division.allValuesD()[genderPicker.selectedRow(inComponent: 1)]
            let semester = genderPicker.selectedRow(inComponent: 2)
            let dateChosen = dateofBirth.date
            let fullUser = FullUser(newUsername: username, newPassword: password.text!, newIsVerified: false, newGender: gender, newDivision: division, newSemester: semester, newBday: dateChosen, newEmail: email.text!)
            
            maker!.pollConnector!.signUp(newUser: fullUser, delegate: self)
            
        } else {
            presentModalView(textForAlert: "Please fill in all input fields!", title: "Not so fast, Johnny!")
        }
        
    }
    
    func presentModalView(textForAlert text: String, title: String = "Alert!") {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        let cancellationAlert = UIAlertController(title: "Your registration will cancel", message: "Are you sure you want to cancel? All registration will be stopped and the account won't be created", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let returnToLogin = UIAlertAction(title: "Return to login", style: UIAlertActionStyle.destructive) { _ in
            self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
        }
        cancellationAlert.addAction(cancelAction)
        cancellationAlert.addAction(returnToLogin)
        self.present(cancellationAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func textDidChange(_ sender: AnyObject) {
        print("textdidChange")
        if let input = email.text {
            checkIfEmailIsAvailable(with: input)
        }
    }
    
    func checkIfEmailIsAvailable(with email: String) {
        print("checking email")
        maker!.pollConnector!.checkEmailAvailability(with: email, delegate: self)
    }
    
    @IBAction func textWillChange(_ sender: AnyObject) {
        print("textwillchange")
        emailVerificationLabel.isHidden = true
    }
    
    func receiveAnnouncement(id: String, announcement data: Any) {
        switch id {
        case "Sign Up":
            if let message = data as? String {
                if message.contains("successful") {
                    let successfullAlert = UIAlertController(title: "Alert", message: (data as! String), preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { _ in
                        self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
                    }
                    successfullAlert.addAction(okAction)
                    self.present(successfullAlert, animated: true, completion: nil)
                } else {
                    presentModalView(textForAlert: "Unsuccessful registration, please try again")
                }
            }
        case "Availability":
            let announcement = String(data: data as! Data, encoding: .utf8)!
            emailVerificationLabel.text = announcement
            emailVerificationLabel.isHidden = false
            if announcement.hasSuffix("is OK") {
                emailVerificationLabel.textColor = UIColor.green
            } else {
                emailVerificationLabel.textColor = UIColor.red
            }
        default:
            presentModalView(textForAlert: data as! String, title: "Network Error")
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[component][row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions[component].count
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let login = segue.destination as? LoginViewController {
            login.username.text = email.text
        }
    }
    
}
