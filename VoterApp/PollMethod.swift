//
//  PollMethod.swift
//  VoterApp
//
//  Created by Lorenzo Leon Robles on 9/14/16.
//  Copyright © 2016 Lorenzo Leon Robles. All rights reserved.
//

import Foundation

enum PollMethod {
    case MAYORITY
    case SECONDROUND
    case CONDORCET
    case BORDA
    case OTHER
    func pollingMethod(_ array: [[Int]]) -> [Double] {
        switch self {
        case .MAYORITY:
            return mayority(votes: array)
        case .CONDORCET:
            return condorcet(votes: array)
        case .SECONDROUND:
            return secondRound(votes: array)
        case .BORDA:
            return borda(votes: array)
        default:
            return [Double]()
            
        }
    }
    
    
    private func mayority(votes: [[Int]]) -> [Double]{
        let votesNum = votes.count
        let candidatesNum = votes[votesNum].count
        var answers = [Double](repeating: 0.0, count: candidatesNum)
        for i in 0..<candidatesNum {
            for vote in votes {
                if vote.count >= i {
                    answers[i] += vote[i]==1 ? 1 : 0
                }
            }
            answers = answers.map { $0 / Double(candidatesNum) }
            
        }
        return answers
    }
    private func secondRound(votes: [[Int]]) -> [Double] {
        let votesNum = votes.count
        let candidatesNum = votes[votesNum].count
        
        
        var orderedWinners = mayority(votes: votes)
        let firstWinner = orderedWinners.max()! //find first firstPreference winner
        let firstWinnersIndex = orderedWinners.index(of: firstWinner)!
        orderedWinners[firstWinnersIndex] = 0
        let secondWinner = orderedWinners.max()! //find second firstPreference winner
        let secondWinnerIndex = orderedWinners.index(of: secondWinner)
        
        var answers = [Double](repeating: 0.0, count: candidatesNum)
        
        for i in [firstWinnersIndex, secondWinnerIndex] {
            for vote in votes {
                answers[i!] += vote[i!]==1 ? 1 : 0
            }
            answers = answers.map { $0 / Double(candidatesNum) }
            
        }
        
        
        return answers
    }
    
    private func condorcet(votes: [[Int]]) -> [Double] {
        let votesNum = votes.count
        let candidatesNum = votes[votesNum].count
        let answers = [Double](repeating: 0.0, count: candidatesNum)
        
        //TODO
        
        return answers
    }
    
    private func borda(votes: [[Int]]) -> [Double] {
        let votesNum = votes.count
        let candidatesNum = votes[votesNum].count
        let answers = [Double](repeating: 0.0, count: candidatesNum)
        
        //TODO
        
        return answers
    }
    
    private func compare(preference1: Int, preference2: Int) -> Bool?{
        let result: Bool? = nil
        
        if abs(preference1)<abs(preference2){
            return true
        }
        
        return result
    }
    
    
}

