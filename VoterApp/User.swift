//
//  User.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class User {
    let username: String
    let password: String
    let userID: String?
    private var verified: Bool
    
    init(newUsername: String, newPassword: String, newUserID: String?, isVerified: Bool) {
        username = newUsername
        password = newPassword
        userID = newUserID
        verified = isVerified
    }
    
    func setVerified(ver: Bool) {
        verified = ver
    }
    
    func isVerified() -> Bool {
        return verified
    }
    
}

class FullUser: User {
    let gender: Gender
    let division: Set<Division>
    let age: Int
    let email: String
    let semester: Int?
    private static let num = Set<Int>(1...20)
    
    
    init(newUsername: String, newPassword: String, isVerified: Bool, newGender: Gender, newDivision: Set<Division>, newSemester: Int?, newAge: Int, newEmail: String) {
        gender = newGender
        division = newDivision
        semester = FullUser.semester(newNum: newSemester)
        age = newAge
        email = newEmail
        
        super.init(newUsername: newUsername, newPassword: newPassword, newUserID: nil, isVerified: false)
    }
    
    static func semester(newNum: Int?) -> Int{
        if let newSemester = newNum {
            if FullUser.num.contains(newSemester) {
                return newSemester
            } else {
                return 1
            }
        } else {
            return 1
        }
    }
    
    func putInURLRequest(newRequest: URLRequest) -> URLRequest {
        var request = newRequest
        request.addValue(username, forHTTPHeaderField: "Username")
        request.addValue(password, forHTTPHeaderField: "Password")
        request.addValue(gender.getString(), forHTTPHeaderField: "Gender")
        request.addValue(getDivisions(), forHTTPHeaderField: "Divisions")
        
        if let sem = semester {
            request.addValue("\(sem)", forHTTPHeaderField: "Semester")
        }
        request.addValue("\(age)", forHTTPHeaderField: "Age")
        request.addValue(email, forHTTPHeaderField: "Email")
        return request
    }
    
    private func getDivisions() -> String{
        var divString = ""
        for div in division {
            divString.append(", \(div)")
        }
        return divString
    }
    
    
}

enum Gender {
    case Male
    case Female
    case Else
    func getString() -> String{
        switch self {
        case .Male:
            return "M"
        case .Female:
            return "F"
        default: return "NS"
        }
    }
    static func set(gender: String) -> Gender {
        if gender.contains("F"){
            return Gender.Female
        } else if gender.contains("M") {
            return Gender.Male
        } else {
            return Gender.Else
        }
    }
}

enum Division {
    case DAP
    case DE
    case DIE
    case DEJ
    case DEP
    case DH
    case DAE
    case BIB
    case DG
    case SG
    case SA
    
    func getString() -> String {
        switch self {
        case .BIB:
            return "BIB"
        //TODO
        default:
            return "DAE"
        }
    }
}
