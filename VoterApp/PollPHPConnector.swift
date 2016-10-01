//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollPHPConnector {
    
    static let urlSignIn = "localhost/signin.php"
    static let urlSignUp = "localhost/signup.php"
    static let urlVote = "localhost/vote.php"
    //static let urlAddAnswersToPoll = "www.VoterApp.com/addanswerstopoll.php"
    static let urlUpdatePoll = "localhost/update.php"
    static let urlDeletePoll = "www.VoterApp.com/delete.php"
    static let urlSignOut = "www.VoterApp.com/signout.php"
    static let sesConfig = URLSessionConfiguration.default
    
    private var session: URLSession?
    var pollStore: PollContainerModel?
    
    
    
    //TODO: set response
    func signIn() -> (String?,Bool) {
        if session == nil {
            session = URLSession(configuration: PollPHPConnector.sesConfig, delegate: pollStore, delegateQueue: nil)
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let _ = URLRequest(url: url)
           // doToSession(request: pollStore.user.addToRequest(newRequest: request))
            return ("12345",true)
        } else {
            signOut()
            return signIn()
        }
        
    }
    
    func signUp(newUser: FullUser) -> String {
        if session == nil {
            let url = URL(string: PollPHPConnector.urlSignUp)
            var request = URLRequest(url: url!)
            request = newUser.putInURLRequest(newRequest: request)
            session = URLSession(configuration: PollPHPConnector.sesConfig, delegate: pollStore, delegateQueue: nil)
            //doToSession(request: request)
        } else {
            signOut()
            return signUp(newUser: newUser)
        }
        
        return "FALSE"
        
    }
    
    func signOut() {
        //signout
        if session != nil {
            session!.invalidateAndCancel()
            session = nil
        }
    }
    
    private func doToSession(request: URLRequest){
        if session != nil{
            session!.dataTask(with: request).resume()
        }
    }
    
    
    private func addUserToRequest(user: User, request: URLRequest) -> URLRequest {
        return user.addToRequest(newRequest: request)
    }
}
