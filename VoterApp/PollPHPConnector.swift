//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollPHPConnector {
    
    static let urlSignIn = "www.VoterApp.com/signin.php"
    static let urlSignUp = "www.VoterApp.com/signup.php"
    static let urlIsActivated = "www.VoterApp.com/isactivated.php"
    static let urlPopulatePolls = "www.VoterApp.com/populatepolls.php"
    static let urlVote = "www.VoterApp.com/vote.php"
    static let urlAddAnswersToPoll = "www.VoterApp.com/addanswerstopoll.php"
    static let urlUpdatePoll = "www.VoterApp.com/updatepoll.php"
    static let urlDeletePoll = "www.VoterApp.com/deletepoll.php"
    static let urlSignOut = "www.VoterApp.com/signout.php"
    static let sesConfig = URLSessionConfiguration.default
    
    private var session: URLSession?
    private let pollStore: PollStore
    
    init(newPollStore: PollStore) {
        pollStore = newPollStore
    }
    
    func signIn() {
        if session == nil {
            session = URLSession(configuration: PollPHPConnector.sesConfig, delegate: pollStore, delegateQueue: nil)
            var request = getRequest(urlS: PollPHPConnector.urlSignIn)
            request.addValue(pollStore.user.username, forHTTPHeaderField: "User")
            request.addValue(pollStore.user.password, forHTTPHeaderField: "Password")
            doToSession(request: request)
        } else {
            signOut()
            signIn()
        }
        
    }
    
    func signUp(newUser: FullUser) {
        
    }
    
    func signOut() {
        //signout
        if session != nil {
            let request = getRequest(urlS: PollPHPConnector.urlSignOut)
            doToSession(request: request)
            if session != nil {
                session!.invalidateAndCancel()
            } else {
                session = nil
            }
        }
    }
    
    func isActivated() {
        let request = getRequest(urlS: PollPHPConnector.urlSignOut)
       
        doToSession(request: request)
    }
    
    private func doToSession(request: URLRequest){
        if session != nil{
            session!.dataTask(with: request).resume()
        }
    }
    
    private func getRequest(urlS: String) -> URLRequest {
        let url = URL(string: urlS)!
        var request = URLRequest(url: url)
        request.addValue(pollStore.user.userID!, forHTTPHeaderField: "UserID")
        return request
    }
    
    private func addUserToRequest(user: User, request: URLRequest) -> URLRequest {
    }
}


protocol PollStore: class, URLSessionDelegate {
    func insertPolls(newPollList: [Poll])
    var user: User {
        get
    }
}
