//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollPHPConnector {
    
    static let mainURL = "localhost/"
    static let urlSignIn = mainURL + "signin.php"
    static let urlSignUp = mainURL + "signup.php"
    static let urlVote = mainURL + "vote.php"
    static let urlForgotPassword = mainURL + "forgot.php"
    //static let urlAddAnswersToPoll = "www.VoterApp.com/addanswerstopoll.php"
    static let urlUpdatePoll = mainURL + "update.php"
    static let urlDeletePoll = mainURL + "delete.php"
    static let urlSignOut = mainURL + "signout.php"
    let sesConfig = URLSessionConfiguration.default
    
    private var session: URLSession?
    
    var mainAnnouncer : Announcer
    
    init(announcer main: Announcer) {
        mainAnnouncer = main
    }
    
    
    //TODO: set response
    func signIn(with user: User, delegate: Announcer? = nil){
        if session == nil {
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let request =  user.addToRequest(newRequest: URLRequest(url: url))
            
            doTask(request: request, delegate: delegate, idString: "Sign In")
        } else {
            signOut(delegate: delegate)
            signIn(with: user, delegate: delegate)
        }
        
    }
    
    func signUp(newUser: FullUser, delegate: Announcer? = nil){
        //do we need a session? a shared session?
        //session = nil
        let url = URL(string: PollPHPConnector.urlSignUp)
        let request = newUser.putInURLRequest(newRequest: URLRequest(url: url!))
        doTask(request: request, delegate: delegate, idString: "Sign Up")
        //kill session?
        
    }
    
    func signOut(delegate: Announcer? = nil) {
        if session != nil {
            //signout
            let url = URL(string: PollPHPConnector.urlSignOut)
            let request = URLRequest(url: url!)
            doTask(request: request, delegate: delegate, idString: "Sign Out")
            session!.invalidateAndCancel()
            session = nil
        } else {
            //not necessary to sign out
            //send message to delegate
            let delegate2 = delegate == nil ? mainAnnouncer : delegate!
            delegate2.receiveAnnouncement(id: "No Sign Out", announcement: "user not signed in")
        }
    }
    
    func checkEmailAvailability(with email: String, delegate: Announcer? = nil){
        //post to usernamecheck2 signup.php
        let url = URL(string: PollPHPConnector.urlSignUp)
        var request = URLRequest(url: url!)
        print("checking request email check")
        request.httpBody = "usernamecheck2=\(email)".data(using: .utf8)
        doTask(request: request, delegate: delegate, idString: "Availability")
        
    }
    
    func vote(poll: Poll, vote: [Int], delegate: Announcer? = nil) {
        
    }
    
    func update(poll: Poll? = nil, delegate: Announcer? = nil){
        let url = URL(string: PollPHPConnector.urlUpdatePoll)
        var request = URLRequest(url: url!)
        print("getting update on Polls: \(poll)")
        if poll != nil {
            request.httpBody = "\(poll)".data(using: .utf8)
        }
        doTask(request: request, delegate: delegate, idString: "PollUpdate")
    }
    
    func deletePoll(poll: Poll, delegate: Announcer? = nil) {
        let url = URL(string: PollPHPConnector.urlDeletePoll)
        var request = URLRequest(url: url!)
        print("Deleting Poll: \(poll)")
        request.httpBody = "\(poll)".data(using: .utf8)
        doTask(request: request, delegate: delegate, idString: "PollDelete")
    }
    
    func forgotPassword(email: String, delegate: Announcer? = nil) {
        let url = URL(string: PollPHPConnector.urlForgotPassword)
        var request = URLRequest(url: url!)
        print("Recovering password for email: \(email)")
        request.httpBody = "email=\(email)".data(using: .utf8)
        doTask(request: request, delegate: delegate, idString: "PassWord Forgotten")
    }
    
    
    
    private func doTask(request: URLRequest, delegate: Announcer?, idString: String) {
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
        }
        let delegate2 = delegate == nil ? mainAnnouncer : delegate!
        
        let task = session!.dataTask(with: request) { [unowned delegate2] data, response, error in
            guard let data = data, error == nil else {
                //change error output
                delegate2.receiveAnnouncement(id: "Networking error", announcement: "\(error)")
                return
            }
            
            delegate2.receiveAnnouncement(id: idString, announcement: data)
            
            //Console Output Check Debug
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
        }
        task.resume()
    }
    
}

protocol Announcer: class {
    var lastUpdated : Date? {
        get
    }
    func receiveAnnouncement(id: String, announcement: Any)
}
