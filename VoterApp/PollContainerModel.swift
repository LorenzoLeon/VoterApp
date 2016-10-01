//
//  PollContainerModel.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/18/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

class PollContainerModel: NSObject, URLSessionDataDelegate {
    
    private var polls = Set<Poll>()
    var user: User? {
        didSet {
            polls = Set<Poll>()
        }
    }
    
    init(newUser: User?) {
        user = newUser
    }
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    }
    
    func parseJSON(data1: Data) {
        
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
                self.polls.insert(newpoll)
            }
        }
    }

    
}

