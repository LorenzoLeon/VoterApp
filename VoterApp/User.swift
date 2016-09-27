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
    var userID: String?
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
    
    func addToRequest(newRequest: URLRequest) -> URLRequest {
        var request = newRequest
        request.addValue(username, forHTTPHeaderField: "Username")
        request.addValue(password, forHTTPHeaderField: "Password")
        return request
    }
    
}

class FullUser: User, CustomStringConvertible{
    let gender: Gender
    let division: Set<Division>
    let age: Int
    let email: String
    let semester: Int
    private static let num = Set<Int>(0...20)
    
    
    init(newUsername: String, newPassword: String, isVerified: Bool, newGender: Gender, newDivision: Set<Division>, newSemester: Int, newAge: Int, newEmail: String) {
        gender = newGender
        division = newDivision
        semester = FullUser.semester(newNum: newSemester)
        age = newAge
        email = newEmail
        
        super.init(newUsername: newUsername, newPassword: newPassword, newUserID: nil, isVerified: false)
    }
    
    static func semester(newNum: Int) -> Int{
        if FullUser.num.contains(newNum) {
            return newNum
        } else {
            return 0
        }
    }
    
    func putInURLRequest(newRequest: URLRequest) -> URLRequest {
        var request = self.putInURLRequest(newRequest: newRequest)
        request.addValue("\(gender)", forHTTPHeaderField: "Gender")
        request.addValue(getDivisions(), forHTTPHeaderField: "Divisions")
        request.addValue("\(semester)", forHTTPHeaderField: "Semester")
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
    var description: String {
        
        return "User: \(username) has password: \(password) and is a \(age) years old \(gender), at the \(division.first!) in CIDE in his \(semester)º semester"
    }
    
}

enum Gender: CustomStringConvertible{
    case Male
    case Female
    case Else
    var description: String {
        switch self {
        case .Male:
            return "Male"
        case .Female:
            return "Female"
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

enum Division: String {
    case DAP, DE, DEI, DEJ, DEP, DH, DAE, BIB, DG, SG, SA
    static func allValues() -> [String] {
        return Division.allValuesD().map { $0.rawValue }
    }
    static func allValuesD() -> [Division] {
        return [DAP, DE, DEI, DEJ, DEP, DH, DAE, BIB, DG, SG, SA]
    }
}
