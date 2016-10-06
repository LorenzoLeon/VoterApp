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
    var pollStore: Poller
    
    init(storer: Poller) {
        pollStore = storer
    }
    
    
    
    //TODO: set response
    func signIn(){
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let signInURLRequest = URLRequest(url: url)
            
            
            let signInTask = session!.dataTask(with: signInURLRequest) { [unowned self] data, response, error in
                guard let data = data, error == nil else {                                    // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                //if successful change user... validation and etc
                let responseString = String(data: data, encoding: .utf8)
                if responseString == "success_signin" {
                    //is validated
                    self.pollStore.user?.isVerified = false
                } else {
                    //error handling
                    self.pollStore.failAlert(with: responseString!)
                    print("responseString = \(responseString)")
                }
                
                
            }
            signInTask.resume()
            // doToSession(request: pollStore.user.addToRequest(newRequest: request))
        } else {
            signOut()
            signIn()
        }
        
    }
    
    func signUp(newUser: FullUser){
        //do we need a session?
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
            let url = URL(string: PollPHPConnector.urlSignUp)
            var request = URLRequest(url: url!)
            request = newUser.putInURLRequest(newRequest: request)
            session!.dataTask(with: request) { [unowned self] data, response, error in
                guard let data = data, error == nil else {                                    // check for fundamental networking error
                    print("error=\(error)")
                    return
                }
                let responseString = String(data: data, encoding: .utf8)
                self.pollStore.failAlert(with: responseString!)
                print("responseString = \(responseString)")
            }
        } else {
            signUp(newUser: newUser)
        }
    }
    
    func signOut() {
        if session != nil {
            //signout
            session!.invalidateAndCancel()
            session = nil
        }
    }
    
    private func doToSession(this request: URLRequest){
        if session != nil{
            session!.dataTask(with: request).resume()
        }
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
        
        DispatchQueue.global().async { [unowned self] in
            for newpoll in add {
                self.pollStore.polls += [newpoll]
            }
        }
    }
}
