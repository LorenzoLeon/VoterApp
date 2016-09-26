//
//  Poll.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/14/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation


struct Values {
    static let timeToUpdate: Double = 30 //seconds
    static let oneWeek: Double = 60*60*24*7 //one week in seconds
}

class Poll: Equatable
{
    var pollID: String
    private var creator: String?
    private var question: String
    private var answers:  [String]
    private var vote:  [[Int]]
    private var voters = [String]()
    private var canChangeVote = false
    private var updateTime: Date
    private var creationDate: Date
    private var hasVoted: Bool
    private var isOpen: Bool
    private var userID: String
    
    init(newPollID: String, newCreator: String?, newQuestion: String, newAnswers: [String], canChange: Bool, newCreationDate: Date, newHasVoted: Bool, newVote: [[Int]], newUserID: String, newIsOpen: Bool, newVoters: [String]?) {
        creationDate = newCreationDate
        updateTime = Date()
        userID = newUserID
        pollID = newPollID
        creator = newCreator
        question = newQuestion
        answers = newAnswers
        vote = newVote
        hasVoted = newHasVoted
        canChangeVote = canChange
        isOpen = newIsOpen
        voters = newVoters!.isEmpty ? (hasVoted ? [userID] : [String](repeating: "", count: vote.count)) : newVoters! // if anonymous, voters is only current user (if he has voted)
    }
    
    convenience init(newPollID: String, newQuestion: String, newAnswers: [String], newcreationDate: Date, newHasVoted: Bool, newVote: [[Int]], newUserID: String) {
        self.init(newPollID: newPollID, newCreator: nil, newQuestion: newQuestion, newAnswers: newAnswers, canChange: false, newCreationDate: Date() , newHasVoted: newHasVoted, newVote: newVote, newUserID: newUserID, newIsOpen: false, newVoters: [String]())
        voters = hasVoted ? [userID] : [String](repeating: "", count: vote.count) // if anonymous, voters is only current user (if he has voted)
        isOpen = false
        creationDate  = newcreationDate
    }
    
    convenience init(jsonResults: [String: Any], nuserID: String) {
        let npollID = jsonResults["PollID"] as! String
        let ncreator = jsonResults["Creator"] as! String
        let nquestion = jsonResults["Question"] as! String
        let nanswers = jsonResults["Answers"] as! [String]
        let nchange = jsonResults["CanChange"] as! Bool
        let ncreationDate = jsonResults["CreationDate"] as! Date
        let nhasVoted = jsonResults["HasVoted"] as! Bool
        let nvote = jsonResults["Vote"] as! [[Int]]
        let nisOpen = jsonResults["IsOpen"] as! Bool
        let nvoters = jsonResults["Voters"] as! [String]
        
        self.init(newPollID: npollID, newCreator: ncreator, newQuestion: nquestion, newAnswers: nanswers, canChange: nchange, newCreationDate: ncreationDate, newHasVoted: nhasVoted, newVote: nvote, newUserID: nuserID, newIsOpen: nisOpen, newVoters: nvoters)
        
        
    }
    
    /* TODO
    func addNewAnswers(newAnswers: [String]) -> Bool {
        
        
        if isOpen {
            answers += newAnswers //TODO check size of array.... put zeroes where necessary?
        }
        return isOpen
    }*/
    
    
    func isFinished() -> Bool { //check if it is still open, close if not
        isOpen = !(creationDate.timeIntervalSince(Foundation.Date.init()) > Values.oneWeek) //older than  1 week
        return isOpen
    }
    
    func hasBeenUpdated(lastUpdateInServer: Date) -> Bool {
        return updateTime.timeIntervalSince(lastUpdateInServer) > Values.timeToUpdate
    }
    
    func update(newTime: Date, newAnswers: [String], newHasVoted: Bool, newVoters: [String]?, newVote: [[Int]] ) {
        if !hasBeenUpdated(lastUpdateInServer: newTime) {return}
        updateTime = newTime
        answers = newAnswers
        hasVoted = newHasVoted
        voters = newVoters!.isEmpty ? (hasVoted ? [userID] : [String]()) : newVoters! // if anonymous, voters is only current user (if he has voted)
        vote = newVote
    }
    
    //TODO
    func setVotes(newVotes: [[Int]]) -> Bool{
        if !hasVoted  || canChangeVote {
            vote = newVotes
            if !hasVoted { voters += [userID] }
            hasVoted = true
            return hasVoted
        }
        return false
    }
    
    //TODO
    func getMappedVotes() -> [String:[Int]] {
        var mappedVotes = [String:[Int]]()
        for (i, voter) in voters.enumerated() {
           mappedVotes[voter] = vote[i]
        }
        return mappedVotes
    }
    
    
    func poll(pollingMethod:([[Int]]) -> [Double]) -> [String:Double] {
        var results = pollingMethod(vote)
        var mappedResults =  [String:Double]()
        for (index, answer) in answers.enumerated() {
            mappedResults[answer] = results[index]
        }
        return mappedResults
    }
}


func == (object1: Poll, object2: Poll) -> Bool {
    return object1.pollID == object2.pollID
}
