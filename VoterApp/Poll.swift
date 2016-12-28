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

class Poll: Hashable {
    var pollID: Int?
    var name: String?
    var isOpen: Bool?
    var creationDate: Date?
    var isAnonymous: Bool?
    var creatorID: Int?

    var genders: [Gender]?
    var division: [Division]?
    var years: [Int]?
    var modifiable: Bool?
    var updateTime: Date?
    
    
    var questions: [Question]?
    var voters: [Int]?
    

    var hasVoted: Bool?
    var type: PollMethod?

    
    func makewith(jsonResults: [String: Any], nuserID: Int) -> Poll {
        pollID = jsonResults["id"] as? Int
        name = jsonResults["name"] as? String
        isOpen = jsonResults["isOpen"] as? Int != 0
        creationDate = jsonResults["created"] as? Date
        isAnonymous = jsonResults["anonymous"] as? Int != 0
        creatorID = jsonResults["creatorID"] as? Int
        
        //TODO: Questions
        modifiable = jsonResults["modifiable"] as? Int != 0
        hasVoted = jsonResults["hasVoted"] as? Int != 0
        //vote = jsonResults["Vote"] as? [Int]
        return self
    }
    
    
    func putInURLRequest(newRequest: URLRequest) throws -> URLRequest {
        var request = newRequest
        request.httpMethod  = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: self.toArray(), options: .prettyPrinted)
        return request
    }
    
    func toArray() -> [String:Any] {
        let gend = genders!.map({ (gender: Gender) -> String in
            return gender.rawValue
        })
        let div = division!.map({ (division: Division) -> String in
            return division.rawValue
        })
        let yea = years!.map({ (year: Int) -> String in
            return String(year)
        })
        var anon = 0
        if isAnonymous! {
            anon = 1
        }
        var mod = 0
        if modifiable! {
            mod = 1
        }
        
        let dictionary: [String : Any] = [
            "pollName" : pollID!,
            "anonymous" : "\(anon)",
            "modifiable" : "\(mod)",
            "division" : div.joined(separator: ", "),
            "gender" : gend.joined(separator: ", "),
            "semester": yea.joined(separator: ", "),
            "questions" : questionsToArray() ]
        return dictionary
    }
    
    func questionsToArray() -> [Any] {
        var tempArray = [Any]()
        for question in questions! {
            tempArray.append(question.toArray())
        }
        return tempArray
    }
    /* TODO
     func addNewAnswers(newAnswers: [String]) -> Bool {
     
     
     if isOpen {
     answers += newAnswers //TODO check size of array.... put zeroes where necessary?
     }
     return isOpen
     }*/
    
    func isMine(userID: Int) -> Bool {
        return creatorID == userID
    }
    
    var hashValue: Int {
        return pollID!.hashValue
    }
    
    static func == (lhs: Poll, rhs: Poll) -> Bool {
        return lhs.pollID == rhs.pollID
    }
}

class Question: Equatable{
    var name: String?
    var answer: [String]?
    var pollMethod: PollMethod?
    var votes: [Int]?
    
    var hashValue: Int {
        if name != nil {
            return name!.hashValue
        } else {
            return 0
        }
    }
    
    func toArray() -> [String: String] {
        var tempArray = [String:String]()
        tempArray["name"] = name!
        tempArray["system"] = pollMethod!.getServerValue()
        for (i, answer) in answer!.enumerated() {
            let count = i + 1
            tempArray["ans\(count)"] = answer
        }
        return tempArray
    }
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        if lhs.name != nil && rhs.name != nil {
            return lhs.name == rhs.name
        } else {
            return lhs.hashValue == rhs.hashValue
        }
    }
    
}
