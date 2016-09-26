//
//  trydownloader.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/22/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

protocol HomeModelProtocal: class {
    func itemsDownloaded(items: [Poll])
}


class HomeModel: NSObject, URLSessionDataDelegate {
    
    //properties
    
    weak var delegate: HomeModelProtocal!
    
    var data1 = Data()
    
    let urlPath: String = "http://iosquiz.com/service.php" //this will be changed to the path where service.php lives
    
    
    func downloadItems() {
        
        let url: URL = URL(string: urlPath)!
        var session: URLSession!
        let configuration = URLSessionConfiguration.default
        
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        
        let task = session.dataTask(with: url)
        
        task.resume()
        
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
            self.delegate.itemsDownloaded(items: add)
        }
    }
}
