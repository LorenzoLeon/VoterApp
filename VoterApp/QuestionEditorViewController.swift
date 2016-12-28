//
//  QuestionEditorViewController.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 12/14/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import UIKit

class QuestionEditorViewController: UIViewController, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate {
    
    var pollQuestionReview: CreateQuestionsViewController?
    
    @IBOutlet weak var questionText: UITextField!
    
    @IBOutlet weak var pollMethodPicker: UIPickerView!
    
    @IBOutlet weak var answersTable: UITableView!
    
    var question =  Question()
    
    var answers = [String]()
    
    var canAddAnswer = true

    let pickerOptions = [PollMethod.MAYORITY, PollMethod.SECONDROUND, PollMethod.APROBATORY, PollMethod.BORDA, PollMethod.CONDORCET, PollMethod.DROOP, PollMethod.POLL]
    
    @IBAction func addQuestion(_ sender: Any) {
        if questionIsValid() {
            pollQuestionReview?.add(question: question)
            self.dismiss(animated: true, completion: nil)
        } else {
            //alert
            
            question = Question()
        }
    }
    
    func questionIsValid() -> Bool {
        //TODO: check question length, method and number of answers
        if !questionText.hasText {
            return false
        }
        if questionText.text!.characters.count > 255 {
            return false
        }
        for answer in answers {
            if answer.characters.count > 255 {
                return false
            }
        }
        if pollMethodPicker.selectedRow(inComponent: 0) == -1 {
            return false
        }
        question = Question()
        question.name = questionText.text!
        question.answer = answers
        question.pollMethod = pickerOptions[pollMethodPicker.selectedRow(inComponent: 0)]
        return true
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row].rawValue
    }
    
    @IBAction func editModeAnswers(_ sender: Any) {
        answersTable.setEditing(!answersTable.isEditing, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answers.count
    }
    
    @IBOutlet weak var newAnswerText: UITextField!
    
    @IBOutlet weak var addAnswerButton: UIButton!
    
    @IBAction func addAnswer(_ sender: Any) {
        if newAnswerText.hasText /*&& newAnswerText.text != "Edit New Answer"*/{
            answers.append(newAnswerText.text!)
            DispatchQueue.main.async{ [unowned self] in
                self.answersTable.reloadData()
            }
        }
        checkNumAnswers()
        
        newAnswerText.text = "Edit New Answer"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            answers.remove(at: indexPath.row)
            tableView.endUpdates()
        default: break
            //doNothing
        }
        checkNumAnswers()
    }
    
    func checkNumAnswers() {
        if answers.count == 10 {
            canAddAnswer = false
            addAnswerButton.isEnabled = false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let spec = answers[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell", for: indexPath)
            cell.textLabel?.text = spec
            return cell
    }
    
    
    

}
