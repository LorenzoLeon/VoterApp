//
//  PollContainerModel.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/18/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollContainerModel: NSObject, PollStore {
    
    var connector: PollPHPConnector
    private var polls = [Poll]()
    var user: User
    
    init(newUser: User, newConnector: PollPHPConnector) {
        user = newUser
        connector = newConnector
    }
    
    func insertPolls(newPollList: [Poll]) {
    }
    
    func changeUser(newUser: User) {
        polls = [Poll]()
        user = newUser
        connector.signIn()
    }
}

