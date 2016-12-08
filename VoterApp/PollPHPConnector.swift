//
//  PollPHPConnector.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

enum Announcements: String {
    case SIGNIN, SIGNOUT, SIGNUP, CHECKEMAIL, VOTE, EDITPROFILE, UPDATE, DELETE, FORGOT, USERMALFORMED, NETWORKINGERROR, ERROR, CREATE, CHECKSTATUS
}

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
    
    func askServer(to taskID: Announcements, with requestObject: Any? = nil, extra requestObject2: Any? = nil, announceMessageTo secondaryDelegate: Announcer? = nil) {
        switch taskID {
        case .CHECKSTATUS:
            self.checkStatus()
        case .SIGNIN:
            self.signIn(with: requestObject as? User, announceMessageTo: secondaryDelegate)
        case .SIGNOUT:
            self.signOut(announceMessageTo: secondaryDelegate)
        case .SIGNUP:
            self.signUp(newUser: requestObject as? FullUser, announceMessageTo: secondaryDelegate)
        case .CHECKEMAIL:
            self.checkEmailAvailability(with: requestObject as? String, announceMessageTo: secondaryDelegate)
        case .VOTE:
            if let poll = requestObject as? Poll, let vote = requestObject2 as? [Int] {
                self.vote(poll: poll, vote: vote, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .VOTE, announcement: "Not registered")
            }
        case .EDITPROFILE:
            if let user = requestObject as? User, let fullUser = requestObject2 as? FullUser {
                self.editProfile(from: user, to: fullUser, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .EDITPROFILE, announcement: "Request Malformed")
            }
        case .UPDATE:
            self.update(poll: requestObject as? Poll, announceMessageTo: secondaryDelegate)
        case .DELETE:
            if let poll = requestObject as? Poll {
                self.deletePoll(poll: poll, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .DELETE, announcement: "Request Malformed")
            }
        case .FORGOT:
            if let email = requestObject as? String {
                self.forgotPassword(email: email, announceMessageTo: secondaryDelegate)
            } else {
                secondaryDelegate?.receiveAnnouncement(id: .FORGOT, announcement: "Request Malformed")
            }
        default:
            secondaryDelegate?.receiveAnnouncement(id: .ERROR, announcement: "No such action exists in server")
            break
        }
    }
    
    private func checkStatus() {
        let url = URL(string: PollPHPConnector.urlSignIn)!
        let request = URLRequest(url: url)
        doTask(request: request, announceMessageTo: mainAnnouncer, idString: .CHECKSTATUS)
    }
    
    //TODO: set response
    private func signIn(with user: User? ,announceMessageTo delegate: Announcer?){
        if user != nil {
            let url = URL(string: PollPHPConnector.urlSignIn)!
            let request =  user!.addToRequest(newRequest: URLRequest(url: url))
            doTask(request: request, announceMessageTo: delegate, idString: .SIGNIN)
        } else {
            delegate?.receiveAnnouncement(id: .USERMALFORMED, announcement: "You didn't pass correct user details, try again")
        }
    }
    
    private func signUp(newUser: FullUser?, announceMessageTo delegate: Announcer?){
        //do we need a session? a shared session?
        //session = nil
        if newUser != nil {
            let url = URL(string: PollPHPConnector.urlSignUp)
            let request = newUser!.putInURLRequest(newRequest: URLRequest(url: url!))
            print("Doing Sign up task")
            doTask(request: request, announceMessageTo: delegate, idString: .SIGNUP)
            //kill session?
        } else {
            delegate?.receiveAnnouncement(id: .USERMALFORMED, announcement: "You didn't pass correct user details, try again")
        }
        
    }
    
    private func signOut(announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlSignOut)
        let request = URLRequest(url: url!)
        doTask(request: request, announceMessageTo: delegate, idString: .SIGNOUT)
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
        doTask(request: request, announceMessageTo: delegate, idString: .CHECKEMAIL)
        
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
            doTask(request: request, announceMessageTo: delegate, idString: .EDITPROFILE)
        }
        
    }
    
    private func update(poll: Poll? = nil, announceMessageTo delegate: Announcer?){
        let url = URL(string: PollPHPConnector.urlUpdatePoll)
        var request = URLRequest(url: url!)
        var rString = "updateTime="
        if poll != nil {
            let pollUpdateTime = DateFormatter.localizedString(from: poll!.updateTime, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
            rString.append(pollUpdateTime)
            rString.append("&pollID=\(poll)")
        } else {
            let updateTime = DateFormatter.localizedString(from: mainAnnouncer.lastUpdated!, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none)
            rString.append(updateTime)
        }
        request.httpMethod  = "POST"
        request.httpBody = rString.data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: .UPDATE)
    }
    
    private func deletePoll(poll: Poll, announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlDeletePoll)
        var request = URLRequest(url: url!)
        request.httpMethod  = "POST"
        request.httpBody = "pollID=\(poll)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: .DELETE)
    }
    
    private func forgotPassword(email: String, announceMessageTo delegate: Announcer?) {
        let url = URL(string: PollPHPConnector.urlForgotPassword)
        var request = URLRequest(url: url!)
        request.httpMethod  = "POST"
        request.httpBody = "email=\(email)".data(using: .utf8)
        doTask(request: request, announceMessageTo: delegate, idString: .FORGOT)
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

    private func doTask(request: URLRequest, announceMessageTo delegate: Announcer?, idString: Announcements) {
        if session == nil {
            session = URLSession(configuration: sesConfig, delegate: nil, delegateQueue: nil)
        }
        let ss = String(data: request.httpBody!, encoding: .utf8)
        print("request: \(ss)")
        let task = session!.dataTask(with: request) { [unowned self] data, response, error in
            
            guard let data = data, error == nil else {
                //change error output
                print("error is: \(error)")
                DispatchQueue.main.async {
                    delegate?.receiveAnnouncement(id: .NETWORKINGERROR, announcement: "\(error)")
                }
                return
            }
            DispatchQueue.main.async {
                self.mainAnnouncer.receiveAnnouncement(id: idString, announcement: data)
                delegate?.receiveAnnouncement(id: idString, announcement: data)
            }
            //Console Output Check Debug
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
        }
        task.resume()
    }
    
}

