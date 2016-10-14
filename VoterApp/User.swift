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
    var isVerified: Bool?
    
    init(newUsername: String, newPassword: String, newUserID: String?, newIsVerified: Bool?) {
        username = newUsername
        password = newPassword
        userID = newUserID
        isVerified = newIsVerified
    }
    
    func addToRequest(newRequest: URLRequest) -> URLRequest {
        var request = newRequest
        request.addValue(username, forHTTPHeaderField: "u")
        request.addValue(password, forHTTPHeaderField: "p")
        return request
    }
    
}

class FullUser: User, CustomStringConvertible{
    let gender: Gender
    let division: Division
    let bday: Date
    let email: String
    let semester: Int
    private static let num = Set<Int>(0...20)
    
    
    init(newUsername: String, newPassword: String, newIsVerified: Bool?, newGender: Gender, newDivision: Division, newSemester: Int, newBday: Date, newEmail: String) {
        gender = newGender
        division = newDivision
        semester = FullUser.semester(newNum: newSemester)
        bday = newBday
        email = newEmail
        
        super.init(newUsername: newUsername, newPassword: newPassword, newUserID: nil, newIsVerified: false)
    }
    
    static func semester(newNum: Int) -> Int{
        if FullUser.num.contains(newNum) {
            return newNum
        } else {
            return 0
        }
    }
    
    func putInURLRequest(newRequest: URLRequest) -> URLRequest {
        //"u="+u+"&e="+e+"&p="+p1+"&g="+g+"&b="+b+"&d="+d+"&s="+s
        let age = DateFormatter.localizedString(from: bday, dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.none).replacingOccurrences(of: "/", with: "-")
        var request = addToRequest(newRequest: newRequest)
        request.addValue("\(email)", forHTTPHeaderField: "e")
        request.addValue("\(gender)", forHTTPHeaderField: "g")
        request.addValue("\(division)", forHTTPHeaderField: "d")
        request.addValue("\(semester)", forHTTPHeaderField: "s")
        request.addValue("\(age)", forHTTPHeaderField: "b")
        return request
    }
    
    var description: String {
        let dateChosen = bday
        let datech  = dateChosen.timeIntervalSinceNow
        let age = -Int(datech/(60*60*24*365))
        return "User: \(username) has password: \(password) and is a \(age) years old \(gender), at the \(division) in CIDE in his \(semester)º semester"
    }
    
}

enum Gender: String {
    case Male
    case Female
    case Else
    
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
