//
//  PollMethod.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/14/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

protocol Announcer: class {
    var lastUpdated : Date? {
        get
    }
    func receiveAnnouncement(id: Announcements, announcement: [String:Any]?)
}

protocol Poller: Announcer {
    var user: String? {
        get
        set
    }
    var userID: Int? {
        get
        set
    }
    var pollList: PollList? {
        get
    }
    var listeners: [PollListener] {
        get
    }
    var pollConnector: PollPHPConnector? {
        get
    }
    func notifyListeners()
}

protocol PollListener: class {
    func pollsHaveChanged()
}

enum PollMethod: String {
    case MAYORITY
    case SECONDROUND
    case APROBATORY
    case BORDA
    case CONDORCET
    case DROOP
    case POLL
    case OTHER
    
    func getServerValue() -> String {
        switch self {
        case .MAYORITY:
            return  "MREL"
        case .SECONDROUND:
            return  "2ROU"
        case .APROBATORY:
            return  "APRO"
        case .BORDA:
            return "BORD"
        case .CONDORCET:
            return "COND"
        case .DROOP:
            return"DROO"
        case .POLL:
            return "POLL"
        default:
            return "OTHE"
        }
    }
}

enum Announcements: String {
    case SIGNIN, SIGNOUT, SIGNUP, CHECKEMAIL, VOTE, EDITPROFILE, UPDATE, DELETE, FORGOT, REQUESTMALFORMED, NETWORKINGERROR, ERROR, CREATE, CHECKSTATUS
}
