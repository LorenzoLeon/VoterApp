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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[component][row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions[component].count
    }
    
    
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
            
            maker!.pollConnector!.askServer(to: .SIGNUP, with: fullUser, announceMessageTo: self)
            
        } else {
            presentModalView(textForAlert: NSLocalizedString("Fill_All", comment: "Please Fill in all the fields"), title: NSLocalizedString("HoldEm", comment: "Hold your Horses"))
        }
        
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
    
    @IBAction func textWillChange(_ sender: AnyObject) {
        emailVerificationLabel.isHidden = true
    }
    
    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    func checkIfEmailIsAvailable(with email: String) {
        maker!.pollConnector!.askServer(to: .CHECKEMAIL, with: email, announceMessageTo: self)
    }
    
    func receiveAnnouncement(id: Announcements, announcement data: [String:Any]?) {
        let echo = data?["echo"] as? String
        switch id {
        case .SIGNUP:
            let successfullAlert = UIAlertController(title: NSLocalizedString("Success", comment: "Success!"), message: NSLocalizedString("RegSuccCheckEmail", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
                self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
            }
            successfullAlert.addAction(okAction)
            self.present(successfullAlert, animated: true, completion: nil)
        case .CHECKEMAIL:
            //if echo != nil {
            //TODO: change echo to NSLOCALIZED STRING
            //print("Announcement Register View: \(echo!)")
            emailVerificationLabel.text = echo!
            emailVerificationLabel.isHidden = false
            if (data?["status"] as! Bool) {
                //print("is ok")
                emailVerificationLabel.textColor = UIColor.green
                //unblock button
            } else {
                //print("is not ok; change to red")
                emailVerificationLabel.textColor = UIColor.red
                //block button
            }
        //}
        case .NETWORKINGERROR:
            presentModalView(textForAlert: NSLocalizedString("SomeWrong", comment: "Something Went Wrong"), title: NSLocalizedString("NetError", comment: "Network Error"))
        case .ERROR:
            if echo != nil {
                presentModalView(textForAlert: NSLocalizedString(echo!, comment: ""), title: NSLocalizedString("SomeWrong", comment: "Something Went Wrong"))
            } else {
                //unknown error
                presentModalView(textForAlert: NSLocalizedString("UnsuccReg", comment: ""))
            }
        case .REQUESTMALFORMED:
            presentModalView(textForAlert: NSLocalizedString(echo!, comment: ""), title: NSLocalizedString("Sorry", comment: ""))
        case .CHECKSTATUS:
            let successfullAlert = UIAlertController(title: NSLocalizedString("HoldEm", comment: ""), message: NSLocalizedString("AlreadySignedIn", comment: "You were already signed in"), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
                self.performSegue(withIdentifier: "goToMain", sender: self)
            }
            successfullAlert.addAction(okAction)
            print("Login view already login")
            self.present(successfullAlert, animated: true, completion: nil)
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let login = segue.destination as? LoginViewController {
            login.username.text = email.text
        }
    }
    
}
