//
//  PollContainerModel.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/18/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollContainerModel: PollStore {
    
    private var pollDownloader: PollDownloader?
    private var polls = [Poll]()
    var user: User {
        didSet {
            //TODO
            signIn()
            populate()
        }
    }
    
    
    let urlPathPopulate = "http://voterapp.com/service.php" //this will be changed to the path where service.php lives
    let urlPathSignIn = "http://voterapp.com/signin.php"
    let urlPathVote = "http://voterapp.com/signin.php"
    let urlPath = "http://voterapp.com/signin.php"
    var urlConfig = URLSessionConfiguration.default
    var newSession: URLSession?
    
        
    
    init(newUser: User) {
        user = newUser
    }
    
    func populate() {
        pollDownloader = PollDownloader(newPollStore: self)
        
        let url = URL(fileURLWithPath: urlPathPopulate)
        var newRequest = URLRequest(url: url)
        newRequest.addValue(user.username, forHTTPHeaderField: "Username")
        pollDownloader!.downloadItems(request: newRequest, session: newSession!)
    }
    
    func signIn() {
        newSession = URLSession(configuration: urlConfig, delegate: pollDownloader, delegateQueue: nil)
        newSession
    }
    
    func signOut() {
        
    }
    
    func insertPolls(newPollList: [Poll]) {
        polls = newPollList
    }
    
    func getRequest (url: URL) -> URLRequest{
        var newRequest = URLRequest(url: url)
        newRequest.addValue(user.username, forHTTPHeaderField: "Username")
        return newRequest
    }
}

class User {
    var username: String
    var password: String
    var userID: String
    
    init(newUsername: String, newPassword: String, newUserID: String) {
        username = newUsername
        password = newPassword
        userID = newUserID
    }
    
}
