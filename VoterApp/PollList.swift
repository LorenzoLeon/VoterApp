//
//  PollList.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 12/27/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollList {
    let poller: Poller
    var polls: [Int:(poll: Poll, date: Date)]
    
    init(newPoller: Poller) {
        poller = newPoller
        polls = [Int:(poll: Poll, date: Date)]()
    }
    
    func reset() {
        polls = [Int:(poll: Poll, date: Date)]()
    }
    
    func updatePollList(with poll: [String:Any], andDate date: Date? = nil) -> Bool {
        let trueDate = date == nil ? Date() : date!
        if let index = poll["pollID"] as? Int {
            polls[index] = (Poll().makewith(jsonResults: poll, nuserID: poller.userID!), trueDate)
            return true
        }
        return false
    }
    
    func delete(pollID poll: Poll) -> Bool {
        return delete(pollID: poll.pollID!)
    }
    
    func delete(pollID: Int) -> Bool {
        if let _ = polls[pollID] {
            polls.removeValue(forKey: pollID)
            return true
        }
        return false
    }
    
    func add(poll: Poll) -> Bool{
        if let _ = polls[poll.pollID!] {
            return false
        } else {
            polls[poll.pollID!] = (poll, poll.updateTime!)
            return false
        }
    }
    
    func getPoll(poll: Int) -> (poll: Poll, date: Date)? {
        return polls[poll]
    }
    
    func getFirstUpdatedPoll() -> (poll: Poll, date: Date)? {
        if let maxPoll = polls.max(by: { (key1: (_: Int, value: (_: Poll, date: Date)), key2: (_: Int, value: (_: Poll, date: Date))) -> Bool in
            key1.value.date.compare(key2.value.date) == .orderedDescending
        }) {
            if let index = polls[maxPoll.key] {
                return index
            }
        }
        return nil
    }
    
    func getLastUpdatedPoll() -> (poll: Poll, date: Date)?{
        if let minPoll = polls.min(by: { (key1: (_: Int, value: (_: Poll, date: Date)), key2: (_: Int, value: (_: Poll, date: Date))) -> Bool in
            key1.value.date.compare(key2.value.date) == .orderedAscending
        }) {
            if let index = polls[minPoll.key] {
                return index
            }
        }
        return nil
    }
    
    func myPolls() -> [Poll] {
        return polls.filter({ ( a : (_: Int, value: (poll: Poll, _: Date))) -> Bool in
            return a.value.poll.isMine(userID: poller.userID!)
        }).map({ (a: (key: Int, value: (poll: Poll, date: Date))) -> Poll in
            return a.value.poll
        })
    }
    
    func votedPolls() -> [Poll] {
        return polls.filter({ ( a : (_: Int, value: (poll: Poll, _: Date))) -> Bool in
            return a.value.poll.hasVoted!
        }).map({ (a: (key: Int, value: (poll: Poll, date: Date))) -> Poll in
            return a.value.poll
        })
    }
    
    func openNotVotedPolls() -> [Poll] {
        return polls.filter({ ( a : (_: Int, value: (poll: Poll, _: Date))) -> Bool in
            return a.value.poll.isOpen! && !a.value.poll.hasVoted!
        }).map({ (a: (key: Int, value: (poll: Poll, date: Date))) -> Poll in
            return a.value.poll
        })
    }
    
}
