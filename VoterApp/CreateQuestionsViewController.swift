//
//  CreateQuestionsViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 12/14/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class CreateQuestionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Announcer {
    
    var maker: Poller?
    var poll: Poll?
    var lastUpdated: Date?
    
    @IBOutlet weak var pollNameLabel: UILabel!
    
    @IBOutlet weak var anonymousLabel: UILabel!

    @IBOutlet weak var modifiableLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var divisionLabel: UILabel!
    
    @IBOutlet weak var yearsLabel: UILabel!
    
    var questions = [Question]()
    
    var canAddQuestion = true
    
    @IBOutlet weak var questionTable: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async{ [unowned self] in
            self.questionTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pollNameLabel.text = String(poll!.pollID!)
        anonymousLabel.text = String(describing: poll!.isAnonymous!)
        modifiableLabel.text = String(describing: poll!.modifiable!)
        if let gend = poll?.genders?.map({ (gender: Gender) -> String in
            return gender.rawValue
        }) {
            genderLabel.text = gend.joined(separator: ", ")
        }
        if let div = poll?.division?.map({ (division: Division) -> String in
            return division.rawValue
        }) {
            divisionLabel.text = div.joined(separator: ", ")
        }
        if let years = poll?.years?.map({ (year: Int) -> String in
            return String(year)
        }) {
            yearsLabel.text = years.joined(separator: ", ")
        }

    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = questions.count
        if canAddQuestion {count += 1}
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if canAddQuestion && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath)
            cell.textLabel?.text = "Create a New Question!"
            return cell
        } else {
            var count = indexPath.row
            if canAddQuestion {
                count -= 1
            }
            let spec = questions[count]
            let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell2", for: indexPath)
            cell.textLabel?.text = spec.name
            cell.detailTextLabel?.text = "Number of answers= \(spec.answer!.count)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && canAddQuestion {
            performSegue(withIdentifier: "createQuestion", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "createQuestion":
            let destination = segue.destination as! QuestionEditorViewController
            destination.pollQuestionReview = self
        default:
            break
        }
    }
    

    func add(question: Question) {
        if canAddQuestion {
            questions.append(question)
        }
        
        if questions.count == 10 {
            canAddQuestion = false
        }
    }
    
    @IBAction func submitPoll(_ sender: Any) {
        if checkForPoll() {
            poll?.questions = questions
            maker?.pollConnector?.askServer(to: .CREATE, with: poll, announceMessageTo: self)
            
        } else {
            presentModalView(textForAlert: "You have to submit at least one question for this poll!")
        }
    }
    
    func checkForPoll() -> Bool {
        
        let count = questions.count
        
        if count >= 10 {
            canAddQuestion = false
        }

        if  count > 0  && count < 11{
            return true
        }
        return false
    }

    func presentModalView(textForAlert text: String, title: String = NSLocalizedString("Alert", comment: "")) {
        let cancellationAlert = UIAlertController(title: title, message: text, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil)
        cancellationAlert.addAction(okAction)
        self.present(cancellationAlert, animated: true, completion: nil)
    }
    
    private func presentDismissAllert(title: String, message: String) {
        let successfullAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default) { _ in
            self.performSegue(withIdentifier: "goToMain", sender: self)
        }
        successfullAlert.addAction(okAction)
        self.present(successfullAlert, animated: true, completion: nil)
    }
    
    func receiveAnnouncement(id: Announcements, announcement data: [String:Any]?) {
        let echo = data?["echo"] as? String
        
        switch id {
        case .CREATE:
            presentDismissAllert(title: "YAY!" , message: NSLocalizedString("Success", comment: ""))

        case .ERROR:
            if echo != nil {
                presentModalView(textForAlert: echo!)
            } else {
                presentModalView(textForAlert: NSLocalizedString("SomeWrong", comment: "Something went Wrong"), title: NSLocalizedString("UnableToSignIn", comment: "We could not sign you in."))
            }
        case .REQUESTMALFORMED:
            presentModalView(textForAlert: NSLocalizedString("Fill_All", comment: "Ask user to fill all fields"))
        case .NETWORKINGERROR:
            presentModalView(textForAlert: NSLocalizedString("UnknownNetError", comment: "Unknown Network Problem; please check your connection status"), title: NSLocalizedString("SomeWrong", comment: "Something went Wrong"))
        case .CHECKSTATUS:
            presentDismissAllert(title: NSLocalizedString("HoldEm", comment: ""), message: NSLocalizedString("NotSignedIN", comment: "You are not signed in"))
        default:
            break
        }

    }
    
    @IBAction func editQuestions(_ sender: Any) {
        questionTable.setEditing(!questionTable.isEditing, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            var count = indexPath.row
            if canAddQuestion {
                count -= 1
            }
            questions.remove(at: count)
            tableView.reloadData()
            tableView.endUpdates()
        default: break
            //doNothing
        }
        _ = checkForPoll()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.row == 0 {
            return .none
        } else {
            return .delete
        }
    }
    
}


