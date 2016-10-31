//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollPHPConnector {
    
    static let mainURL = "http://localhost:8888/"
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
    func signIn(with user: User? ,announceMessageTo delegate: Announcer){
        if user != nil {
            if session == nil {
                let url = URL(string: PollPHPConnector.urlSignIn)!
                let request =  user!.addToRequest(newRequest: URLRequest(url: url))
                
                doTask(request: request, announceMessageTo: delegate, idString: "Sign In")
            } else {
                signOut(announceMessageTo: delegate)
                signIn(with: user, announceMessageTo: delegate)
            }
        } else {
            delegate.receiveAnnouncement(id: "User Malformed", announcement: "You didn't pass correct user details, try again")
        }
        
        
    }
    
    func signUp(newUser: FullUser?, announceMessageTo delegate: Announcer){
        //do we need a session? a shared session?
        //session = nil
        if newUser != nil {
            let url = URL(string: PollPHPConnector.urlSignUp)
            let request = newUser!.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Doing Sign up task")
            doTask(request: request, announceMessageTo: delegate, idString: "Sign Up")
            //kill session?
        } else {
            delegate.receiveAnnouncement(id: "User Malformed", announcement: "You didn't pass correct user details, try again")
        }
        
    }
    
    func signOut(announceMessageTo delegate: Announcer) {
        if session != nil {
            //signout
            let url = URL(string: PollPHPConnector.urlSignOut)
            let request = URLRequest(url: url!)
            doTask(request: request, announceMessageTo: delegate, idString: "Sign Out")
            session!.invalidateAndCancel()
            session = nil
        } else {
            //not necessary to sign out
            //send message to delegate
            delegate.receiveAnnouncement(id: "No Sign Out", announcement: "user not signed in")
        }
    }
    
    func checkEmailAvailability(with email: String,announceMessageTo delegate: Announcer){
        //post to usernamecheck2 signup.php
        let url = URL(string: PollPHPConnector.urlSignUp)
        var request = URLRequest(url: url!)
        print("checking request email check")
        request.httpMethod  = "POST"
        request.httpBody = "usernamecheck2=\(email)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: "Availability")
        
    }
    
    func vote(poll: Poll, vote: [Int], announceMessageTo delegate: Announcer? = nil) {
        
    }
    
    func editProfile(from user: User, to newUser: FullUser, announceMessageTo delegate: Announcer) {
        if newUser.userID == user.userID {
            let url = URL(string: PollPHPConnector.urlVote)
            let request = newUser.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Updating user profile")
            doTask(request: request, announceMessageTo: delegate, idString: "Update Profile")
        }
        
    }
    
    func update(poll: Poll? = nil,announceMessageTo delegate: Announcer){
        let url = URL(string: PollPHPConnector.urlUpdatePoll)
        var request = URLRequest(url: url!)
        print("getting update on Polls: \(poll)")
        if poll != nil {
            request.httpBody = "\(poll)".data(using: .utf8)
        }
        doTask(request: request, announceMessageTo: delegate, idString: "PollUpdate")
    }
    
    func deletePoll(poll: Poll, announceMessageTo delegate: Announcer) {
        let url = URL(string: PollPHPConnector.urlDeletePoll)
        var request = URLRequest(url: url!)
        print("Deleting Poll: \(poll)")
        request.httpBody = "\(poll)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: "PollDelete")
    }
    
    func forgotPassword(email: String, announceMessageTo delegate: Announcer) {
        let url = URL(string: PollPHPConnector.urlForgotPassword)
        var request = URLRequest(url: url!)
        print("Recovering password for email: \(email)")
        request.httpBody = "email=\(email)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: "PassWord Forgotten")
    }
    
    func deleteCookies() {
        if session != nil {
            var cookies =  [HTTPCookie]()
            let strArray = [PollPHPConnector.urlSignIn, PollPHPConnector.urlSignUp, PollPHPConnector.urlVote, PollPHPConnector.urlForgotPassword, PollPHPConnector.urlUpdatePoll, PollPHPConnector.urlDeletePoll, PollPHPConnector.urlSignOut]
            let urlArray = strArray.map { (urlString) -> URL? in
                return URL(string: urlString)
            }
            for url in urlArray {
                if url != nil {
                    if let provCookie = session?.configuration.httpCookieStorage?.cookies(for: url!){
                        cookies += provCookie
                    }
                }
            }
            for cookie in cookies {
                session?.configuration.httpCookieStorage?.deleteCookie(cookie)
            }
            
        }
    }
    
    
    
    private func doTask(request: URLRequest, announceMessageTo delegate: Announcer, idString: String) {
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
        }
        let ss = String(data: request.httpBody!, encoding: .utf8)
        print("request: \(ss)")
        let task = session!.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                //change error output
                print("error is: \(error)")
                DispatchQueue.main.async {
                    delegate.receiveAnnouncement(id: "Networking error", announcement: "\(error)")
                }
                return
            }
            DispatchQueue.main.async {
                //self.mainAnnouncer.receiveAnnouncement(id: idString, announcement: data)
                delegate.receiveAnnouncement(id: idString, announcement: data)
            }
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
