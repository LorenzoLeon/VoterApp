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

class Poll: Hashable, CustomStringConvertible
{
    var pollID: String
    private var creator: String?
    private var question: String
    private var answers:  [String]
    private var vote:  [[Int]]
    private var voters = [String]()
    private var canChangeVote = false
    var updateTime: Date
    var creationDate: Date
    var hasVoted: Bool
    private var isOpen: Bool
    private var userID: String
    private let type: PollMethod
    
    init(newPollID: String, newCreator: String?, newQuestion: String, newAnswers: [String], canChange: Bool, newCreationDate: Date, newHasVoted: Bool, newVote: [[Int]], newUserID: String, newIsOpen: Bool, newVoters: [String]?, newType: PollMethod) {
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
        type = newType
    }
    
    convenience init(newPollID: String, newQuestion: String, newAnswers: [String], newcreationDate: Date, newHasVoted: Bool, newVote: [[Int]], newUserID: String, newType: PollMethod) {
        self.init(newPollID: newPollID, newCreator: nil, newQuestion: newQuestion, newAnswers: newAnswers, canChange: false, newCreationDate: Date() , newHasVoted: newHasVoted, newVote: newVote, newUserID: newUserID, newIsOpen: false, newVoters: [String](), newType: newType)
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
        let nType = jsonResults["Type"] as! PollMethod
        
        self.init(newPollID: npollID, newCreator: ncreator, newQuestion: nquestion, newAnswers: nanswers, canChange: nchange, newCreationDate: ncreationDate, newHasVoted: nhasVoted, newVote: nvote, newUserID: nuserID, newIsOpen: nisOpen, newVoters: nvoters, newType: nType)
        
        
    }
    
    /* TODO
     func addNewAnswers(newAnswers: [String]) -> Bool {
     
     
     if isOpen {
     answers += newAnswers //TODO check size of array.... put zeroes where necessary?
     }
     return isOpen
     }*/
    
    func isMine() -> Bool {
        return creator == userID
    }
    
    func isFinished() -> Bool { //check if it is still open, close if not
        isOpen = !(creationDate.timeIntervalSince(Foundation.Date.init()) > Values.oneWeek) //older than  1 week
        return isOpen
    }
    
    func hasBeenUpdated(since lastUpdateInServer: Date) -> Bool {
        return updateTime.timeIntervalSince(lastUpdateInServer) > Values.timeToUpdate
    }
    
    func updateWith(newTime: Date, newAnswers: [String], newHasVoted: Bool, newVoters: [String]?, newVote: [[Int]] ) {
        if hasBeenUpdated(since: newTime) {
            updateTime = newTime
            answers = newAnswers
            hasVoted = newHasVoted
            voters = newVoters!.isEmpty ? (hasVoted ? [userID] : [String]()) : newVoters! // if anonymous, voters is only current user (if he has voted)
            vote = newVote
        }
    }
    
    //TODO
    func setVotes(to newVotes: [[Int]]) -> Bool{
        if !hasVoted  || canChangeVote {
            vote = newVotes
            if !hasVoted { voters += [userID] }
            hasVoted = true
            return true
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
    
    
    func getPollResults(pollingMethod:([[Int]]) -> [Double]) -> [String:Double] {
        var results = pollingMethod(vote)
        var mappedResults =  [String:Double]()
        for (index, answer) in answers.enumerated() {
            mappedResults[answer] = results[index]
        }
        return mappedResults
    }
    var hashValue: Int {
        return pollID.hashValue
    }
    
    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.pollID == rhs.pollID
    }
    
    var description: String {
        get {
            let date = DateFormatter.localizedString(from: updateTime, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none).replacingOccurrences(of: "/", with: "-")
            return "pollID=\(pollID)&lastupdated=\(date)"
        }
    }
}
