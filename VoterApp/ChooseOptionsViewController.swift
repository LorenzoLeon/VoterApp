//
//  ChooseOptionsViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 12/13/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class ChooseOptionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var maker: Poller?
    var poll: Poll?
    
    var pollsomething: String?
    
    var checked: [[Bool]] = [[false, false, false], (0...11).map({ (_) -> Bool in
        return false
    }), (0...21).map({ (_) -> Bool in
        return false
    })]
    
    @IBOutlet weak var optionsTable: UITableView!
    
    @IBAction func next(_ sender: UIButton) {
        var check = true
        
        for section in checked {
            check = check && section.contains(true)
        }
        
        if check {
            transformChecks()
            performSegue(withIdentifier: "createQuestionsSegue", sender: self)
        } else {
            presentModalView(textForAlert: "You must select at least one option for each section!")
        }
        
    }
    
    private let gender = [Gender.Male, Gender.Female]
    private let divisions = Division.allValuesD()
    
    var divCh: [String] {
        get {
            var pre = [String]()
            pre += ["All Divisions"]
            pre += Division.allValues()
            
            return pre
            
        }
    }
    
    var pickerOptions: [[String]] {
        get {
            let use =  [[NSLocalizedString("All Genders", comment: ""), NSLocalizedString("Male", comment: ""), NSLocalizedString("Female", comment: "")], divCh , (0...21).map {
                if $0 == 0 {
                    return NSLocalizedString("Students and Non Students", comment: "")
                }
                if $0 == 1 {
                    return NSLocalizedString("Not_Student", comment: "")
                } else if $0 < 10 {
                    return String($0 - 1) + "º " + NSLocalizedString("Bachelor", comment: "")
                } else if $0 < 14 {
                    return String($0 - 9) + "º " + NSLocalizedString("Masters", comment: "")
                } else {
                    return String($0 - 13) + "º " + NSLocalizedString("PHD", comment: "")
                }}]
            return use
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerOptions[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let spec = pickerOptions[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "chooseCell", for: indexPath)
        cell.textLabel?.text = spec
        if checked[indexPath.section][indexPath.row]{
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionStrings = [NSLocalizedString("Gender", comment: ""), NSLocalizedString("Division", comment: ""), NSLocalizedString("Year", comment: "")]
        return sectionStrings[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let section = indexPath.section
        let count = checked[section].count
        
        if checked[section][row]{
            if row == 0 {
                var i = 0
                while i < count {
                    changeValueAt(section: section, row: i, to: false)
                    i += 1
                }
            } else {
                changeValue(atCell: indexPath, to: false)
                changeValueAt(section: section, row: 0, to: false)
            }
        } else {
            changeValue(atCell: indexPath, to: true)
            if row == 0 {
                var i = 1
                while i < count {
                    changeValueAt(section: section, row: i, to: true)
                    i += 1
                }
            } else {
                var check = true
                var i = 1
                while i < count {
                    check = check && checked[section][i]
                    i += 1
                }
                if check {
                    changeValueAt(section: section, row: 0, to: true)
                }
            }
        }
    }
    
    func changeValue(atCell indexPath: IndexPath, to newValue: Bool) {
        let cell = optionsTable.cellForRow(at: indexPath)
        
        if newValue {
            cell?.accessoryType = .checkmark
        } else {
            cell?.accessoryType = .none
        }
        checked[indexPath.section][indexPath.row] = newValue
    }
    
    func changeValueAt(section: Int, row: Int, to newValue: Bool) {
        changeValue(atCell: IndexPath(row: row, section: section), to: newValue)
    }
    
    func transformChecks() {
        var finalGenders = [Gender]()
        for i in [1,2] {
            if checked[0][i] {
                finalGenders.append(gender[i-1])
            }
        }
        var finalDivisions = [Division]()
        for i in (1...(divCh.count-1)) {
            if checked[1][i] {
                finalDivisions.append(divisions[i-1])
            }
        }
        var finalYear = [Int]()
        for i in (1...21) {
            if checked[2][i] {
                finalYear.append(i-1)
            }
        }
        poll?.genders = finalGenders
        poll?.division = finalDivisions
        poll?.years = finalYear
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createQuestionsSegue" {
            let destination = segue.destination as? CreateQuestionsViewController
            destination?.poll = poll
            destination?.maker = maker
        }
    }
    
    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }

}
