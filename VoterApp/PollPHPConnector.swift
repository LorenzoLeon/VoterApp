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
    func signIn(with user: User, delegate: Announcer?){
        if session == nil {
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let request =  user.addToRequest(newRequest: URLRequest(url: url))
            
            doTask(request: request, delegate: delegate, idString: "Sign In")
        } else {
            signOut(delegate: delegate)
            signIn(with: user, delegate: delegate)
        }
        
    }
    
    func signUp(newUser: FullUser, delegate: Announcer?){
        //do we need a session? a shared session?
        //session = nil
        let url = URL(string: PollPHPConnector.urlSignUp)
        let request = newUser.putInURLRequest(newRequest: URLRequest(url: url!))
        doTask(request: request, delegate: delegate, idString: "Sign Up")
        //kill session?
        
    }
    
    func signOut(delegate: Announcer?) {
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
    
    func checkEmailAvailability(with email: String, delegate: Announcer?){
        //post to usernamecheck2 signup.php
        let url = URL(string: PollPHPConnector.urlSignUp)
        var request = URLRequest(url: url!)
        print("checking request email check")
        request.httpBody = "usernamecheck2=\(email)".data(using: .utf8)
        doTask(request: request, delegate: delegate, idString: "Availability")
        
    }
    
    func vote() {
        
    }
    
    func getUpdatedPoll(){
        
    }
    
    func deletePoll() {
        
    }
    

    
    private func doTask(request: URLRequest, delegate: Announcer?, idString: String) {
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
        }
        let delegate2 = delegate == nil ? mainAnnouncer : delegate!
        
        let task = session!.dataTask(with: request) { [unowned delegate2] data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(error)")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                delegate2.receiveAnnouncement(id: idString, announcement: responseString)
                print("responseString = \(responseString)")
            }
        }
        task.resume()
    }
    
    //TODO: CHECK
    func parseToJSON(with data1: Data) {
        
        var jsonResult = [Any]()
        
        do{
            jsonResult = try JSONSerialization.jsonObject(with: data1, options: JSONSerialization.ReadingOptions.allowFragments) as! [Any]
            
        } catch {
            print(error)
        }
        var add = [Poll]()
        
        for (_, poll ) in jsonResult.enumerated() {
            let newPoll = Poll(jsonResults: poll as! [String: Any], nuserID: "")
            add += [newPoll]
            
            
        }
        
        //DispatchQueue.global().async { [unowned self] in
        //  for newpoll in add {
        //self.pollStore.polls += [newpoll]
        //}
        //}
    }
}

protocol Announcer: class {
    func receiveAnnouncement(id: String, announcement: String)
}
