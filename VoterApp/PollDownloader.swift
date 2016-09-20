//
//  PollDownloader.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/18/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

protocol PollStore: class {
    func insertPolls(newPollList: [Poll])
    var user: User {
        get
    }
}

class PollDownloader: NSObject , URLSessionDelegate {
    
    weak var pollStore: PollStore?
    var data = Data()
        
    init(newPollStore: PollStore) {
        pollStore = newPollStore
        
    }
    
    
    func downloadItems(request: URLRequest, session: URLSession) {
        session.dataTask(with: request).resume()
    }
    
    func URLSession(session: URLSession, dataTask: URLSessionDataTask, didReceiveData data1: Data) {
        self.data.append(data1)
    }
    
    func URLSession(session: URLSession, task: URLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            print("Failed to download data")
            //TryAgain?
        } else {
            print("Data downloaded")
            self.parseJSON()
            data = Data()
        }
        
    }
    
    func parseJSON() {
        var jsonResult = NSMutableArray()
        do {
            jsonResult = try JSONSerialization.jsonObject(with: self.data, options:JSONSerialization.ReadingOptions.allowFragments) as! NSMutableArray
            var polls = [Poll]()
            for pollDictionary in jsonResult {
                polls += [Poll(jsonResults: pollDictionary as! NSDictionary, nuserID: pollStore!.user.userID)]
            }
            DispatchQueue.main.async(execute: {
                self.pollStore!.insertPolls(newPollList: polls)
            })
            
        } catch let error {
            //TODO
            print(error)
        }
    }
}
