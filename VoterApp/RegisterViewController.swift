//
//  RegisterViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/25/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    
    //TODO
    var maker: Poller?
    @IBOutlet weak var genderPicker: UIPickerView!
    
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var passwordRepeat: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var dateofBirth: UIDatePicker!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var maxView: UIView!
    
    let pickerOptions = [["Male", "Female"], Division.allValues(), (0...20).map {
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
      
       
    }
    
    @IBAction func signUp(_ sender: UIButton) {
        if email.hasText && password.hasText && passwordRepeat.hasText {
            if password.text! != passwordRepeat.text! {
                presentModalView(textForAlert: "Passwords don't match")
                return
            }
            if !email.text!.hasSuffix("@cide.edu") && !email.text!.hasSuffix("@alumnos.cide.edu")
            {
                presentModalView(textForAlert: "Please input a valid CIDE address")
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
            let _ = FullUser(newUsername: username, newPassword: password.text!, isVerified: false, newGender: gender, newDivision: division, newSemester: semester, newBday: dateChosen, newEmail: email.text!)
            //TODO: check php response
            let message = "maker"//maker?.getPHPConnector().signUp(newUser: fullUser)
            let successfullAlert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { _ in
                self.performSegue(withIdentifier: "GoBackToLogIn", sender: self)
                
            }
            successfullAlert.addAction(okAction)
            self.present(successfullAlert, animated: true, completion: nil)


        } else {
            presentModalView(textForAlert: "Please fill in all input fields!")
        }
        
    }

    func presentModalView(textForAlert text: String) {
        let cancellationAlert = UIAlertController(title: "Alert", message: text, preferredStyle: UIAlertControllerStyle.alert)
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[component][row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions[component].count
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let login = segue.destination as? LoginViewController {
            login.username.text = email.text
        }
    }
    

}
