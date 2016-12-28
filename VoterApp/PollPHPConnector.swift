//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollPHPConnector {
    
    static let mainURL = "http://localhost/"
    static let urlSignIn = mainURL + "login.php"
    static let urlSignUp = mainURL + "signup.php"
    static let urlVote = mainURL + "vote.php"
    static let urlCreate = mainURL + "create.php"
    static let urlForgotPassword = mainURL + "forgot.php"
    //static let urlAddAnswersToPoll = "www.VoterApp.com/addanswerstopoll.php"
    static let urlUpdatePoll = mainURL + "update.php"
    static let urlDeletePoll = mainURL + "delete.php"
    static let urlSignOut = mainURL + "logout.php"
    let sesConfig = URLSessionConfiguration.default
    
    private var session: URLSession?
    
    var mainAnnouncer : Announcer
    
    init(announcer main: Announcer) {
        mainAnnouncer = main
    }
    
    func askServer(to taskID: Announcements, with requestObject: Any? = nil, extra requestObject2: Any? = nil, announceMessageTo secondaryDelegate: Announcer? = nil) {
        switch taskID {
        case .CHECKSTATUS:
            self.checkStatus()
        case .CREATE:
            if let poll = requestObject as? Poll {
                self.create(with: poll, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"You didn't pass correct POLL details, try again"])
            }
        case .SIGNIN:
            if let user = requestObject as? User {
                self.signIn(with: user, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"You didn't pass correct USER details, try again"])
            }
            
        case .SIGNOUT:
            self.signOut(announceMessageTo: secondaryDelegate)
        case .SIGNUP:
            if let fullUser = requestObject as? FullUser {
                self.signUp(newUser: fullUser, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"You didn't pass correct USER details, try again"])
            }
        case .CHECKEMAIL:
            self.checkEmailAvailability(with: requestObject as? String, announceMessageTo: secondaryDelegate)
        case .VOTE:
            //TODO: change post to json
            if let poll = requestObject as? Poll, let vote = requestObject2 as? [Int] {
                self.vote(poll: poll, vote: vote, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .VOTE, announcement: ["echo":"Not registered"])
            }
        case .EDITPROFILE:
            if let user = requestObject as? User, let fullUser = requestObject2 as? FullUser {
                self.editProfile(from: user, to: fullUser, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"Request Malformed"])
            }
        case .UPDATE:
            self.update(poll: requestObject as? Int, date: requestObject2 as? Date, announceMessageTo: secondaryDelegate)
        case .DELETE:
            if let poll = requestObject as? Poll {
                self.deletePoll(poll: poll, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"Request Malformed"])
            }
        case .FORGOT:
            if let email = requestObject as? String {
                self.forgotPassword(email: email, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"Request Malformed"])
            }
        default:
            secondaryDelegate?.receiveAnnouncement(id: .ERROR, announcement: ["echo":"No such action exists in server"])
            break
        }
    }
    
    private func checkStatus() {
        let url = URL(string: PollPHPConnector.urlSignIn)!
        let request = URLRequest(url: url)
        doTask(request: request, announceMessageTo: nil)
    }
    
    //TODO: set response
    private func signIn(with user: User ,announceMessageTo delegate: Announcer?){
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let request =  user.addToRequest(newRequest: URLRequest(url: url))
            doTask(request: request, announceMessageTo: delegate)
    }
    
    private func signUp(newUser: FullUser, announceMessageTo delegate: Announcer?){
        //do we need a session? a shared session?
        //session = nil
        
            let url = URL(string: PollPHPConnector.urlSignUp)
            let request = newUser.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Doing Sign up task")
            doTask(request: request, announceMessageTo: delegate)
        
    
        
    }
    
    func create(with poll: Poll, announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlCreate)
        do {
            let request = try poll.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Doing create task")
            doTask(request: request, announceMessageTo: delegate)
        } catch {
            delegate?.receiveAnnouncement(id: .REQUESTMALFORMED, announcement: ["echo":"badlyFormed poll"])
        }
    }
    
    private func signOut(announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlSignOut)
        let request = URLRequest(url: url!)
        doTask(request: request, announceMessageTo: delegate)
        killSession()
    }
    
    private func killSession() {
        session!.invalidateAndCancel()
        session = nil
    }
    
    private func checkEmailAvailability(with email: String?,announceMessageTo delegate: Announcer?){
        //post to usernamecheck2 signup.php
        let url = URL(string: PollPHPConnector.urlSignUp)
        var request = URLRequest(url: url!)
        request.httpMethod  = "POST"
        request.httpBody = "usernamecheck2=\(email)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate)
        
    }
    
    private func vote(poll: Poll, vote: [Int], announceMessageTo delegate: Announcer?) {
        
    }
    
    private func editProfile(from user: User, to newUser: FullUser, announceMessageTo delegate: Announcer?) {
        if newUser.userID == user.userID {
            let url = URL(string: PollPHPConnector.urlVote)
            var request = newUser.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Updating user profile")
            request.httpMethod  = "POST"
            //add body
            doTask(request: request, announceMessageTo: delegate)
        }
        
    }
    
    private func update(poll: Int? = nil, date: Date? = nil, announceMessageTo delegate: Announcer?){
        let url = URL(string: PollPHPConnector.urlUpdatePoll)
        var request = URLRequest(url: url!)
        
        if poll != nil && date != nil {
            let pollUpdateTime = DateFormatter.localizedString(from: date!, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
            request.httpMethod  = "POST"
            request.httpBody = "updateTime=\(pollUpdateTime)&pollID=\(poll)".data(using: .utf8)
        } else if poll == nil && date != nil {
            let updateTime = DateFormatter.localizedString(from: mainAnnouncer.lastUpdated!, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
            request.httpMethod  = "POST"
            request.httpBody = "updateTime=\(updateTime)".data(using: .utf8)
        }

        doTask(request: request, announceMessageTo: delegate)
    }
    
    private func deletePoll(poll: Poll, announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlDeletePoll)
        var request = URLRequest(url: url!)
        request.httpMethod  = "POST"
        request.httpBody = "pollID=\(poll)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate)
    }
    
    private func forgotPassword(email: String, announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlForgotPassword)
        var request = URLRequest(url: url!)
        request.httpMethod  = "POST"
        request.httpBody = "email=\(email)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate)
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

    private func doTask(request: URLRequest, announceMessageTo delegate: Announcer?) {
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
        }
        
        
        let task = session!.dataTask(with: request) { [unowned self] data, response, error in
            
            guard let data = data, error == nil else {
                //change error output
                print("error is: \(error)")
                DispatchQueue.main.async {
                    delegate?.receiveAnnouncement(id: .NETWORKINGERROR, announcement: ["echo":"\(error)"])
                }
                return
            }
            var jsonData: [String:Any]? = nil
            var announce: Announcements? = .ERROR
            do{
                jsonData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any]
                if let announcementString = jsonData?["announcement"] as? String {
                    announce = Announcements(rawValue: announcementString)
                }
            } catch {
                //ERROR do nothing
            }
            
            if announce == nil {
                announce = .ERROR
            }
            
            DispatchQueue.main.async {
                
                self.mainAnnouncer.receiveAnnouncement(id: announce!, announcement: jsonData)
                delegate?.receiveAnnouncement(id: announce!, announcement: jsonData)
            }
            //Console Output Check Debug
            let responseString = String(data: data, encoding: .utf8)
            print("TEST: responseString = \(responseString)")
            
        }
        task.resume()
    }
    
}

