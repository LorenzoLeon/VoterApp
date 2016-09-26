//
//  PollContainerModel.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/18/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollContainerModel: NSObject, PollStore {
    
    private var polls = [Poll]()
    private var data1 =  Data()
    var user: User
    
    init(newUser: User) {
        user = newUser
    }
    
    func insertPolls(newPollList: [Poll]) {
    }
    
    func changeUser(newUser: User) {
        polls = [Poll]()
        user = newUser
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        data1.append(data);
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print("Failed to download data")
        }else {
            print("Data downloaded")
            parseJSON()
        }
        
    }
    
    func parseJSON() {
        
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
        
        DispatchQueue.global().async {
            self.insertPolls(newPollList: add)
        }
    }

    
}

