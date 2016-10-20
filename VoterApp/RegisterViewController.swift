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
    
    private let pickerOptions = [[NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")], Division.allValues(), (0...20).map {
        if $0 == 0 {
            return NSLocalizedString("Not_Student", comment: "")
        }else if $0 < 9 {
            return String($0) + "º " + NSLocalizedString("Bachelor", comment: "")
        } else if $0 < 13 {
            return String($0 - 8) + "º " + NSLocalizedString("Masters", comment: "")
        } else {
            return String($0 - 12) + "º " + NSLocalizedString("PHD", comment: "")
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
                presentModalView(textForAlert: NSLocalizedString("Pass_NoMatch", comment: "Passwords don't match"), title: NSLocalizedString("HoldEm", comment: "Hold your horses!"))
                return
            }
            if !email.text!.hasSuffix("@cide.edu") && !email.text!.hasSuffix("@alumnos.cide.edu")
            {
                presentModalView(textForAlert: NSLocalizedString("Please_Input", comment: "Please input a valid CIDE address"), title: NSLocalizedString("AreYouFrom", comment: "Are you from around?"))
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
            
            maker!.pollConnector!.signUp(newUser: fullUser, announceMessageTo: self)
            
        } else {
            presentModalView(textForAlert: NSLocalizedString("Fill_All", comment: "Please Fill in all the fields"), title: NSLocalizedString("HoldEm", comment: "Hold your Horses"))
        }
        
    }
    
    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        let cancellationAlert = UIAlertController(title: NSLocalizedString("YourRegCancel", comment: "Your registration will cancel"), message: NSLocalizedString("AreYouSureRegCancel", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        let returnToLogin = UIAlertAction(title: NSLocalizedString("ReturnToLogin", comment: "Return to login"), style: UIAlertActionStyle.destructive) { _ in
            self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
        }
        cancellationAlert.addAction(cancelAction)
        cancellationAlert.addAction(returnToLogin)
        self.present(cancellationAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func textDidChange(_ sender: AnyObject) {
        if let input = email.text {
            print("email to check is: \(input)")
            checkIfEmailIsAvailable(with: input)
        }
    }
    
    func checkIfEmailIsAvailable(with email: String) {
        maker!.pollConnector!.checkEmailAvailability(with: email, announceMessageTo: self)
    }
    
    @IBAction func textWillChange(_ sender: AnyObject) {
        emailVerificationLabel.isHidden = true
    }
    
    func receiveAnnouncement(id: String, announcement data: Any) {
        print("Id String received in Register: \(id)")
        switch id {
        case "Sign Up":
            let dat = String(data: data as! Data, encoding: .utf8)
            if let message = dat {
                if message.contains("success") {
                    let successfullAlert = UIAlertController(title: NSLocalizedString("Success", comment: "Success!"), message: NSLocalizedString("RegSuccCheckEmail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
                        self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
                    }
                    successfullAlert.addAction(okAction)
                    self.present(successfullAlert, animated: true, completion: nil)
                } else {
                    presentModalView(textForAlert: NSLocalizedString("UnsuccReg", comment: ""))
                }
            }
        case "Availability":
            let dat = data as! Data
            let announcement = String(data: dat, encoding: .utf8)!
            print("Announcement Register View: \(announcement)")
            emailVerificationLabel.text = announcement
            emailVerificationLabel.isHidden = false
            if announcement.hasSuffix("is OK") {
                print("is ok")
                emailVerificationLabel.textColor = UIColor.green
            } else {
                print("is not ok; change to red")
                emailVerificationLabel.textColor = UIColor.red
            }
        default:
            presentModalView(textForAlert: data as! String, title: NSLocalizedString("NetError", comment: "Network Error"))
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
