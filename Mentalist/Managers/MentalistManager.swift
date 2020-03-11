//
//  MentalistManager.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import Foundation

class MentalistManager {
    static let instance = MentalistManager()
    
    // Letters game
    var collectionViewElements:[String] = [""]
    var clickedCells: Int = 0
    var totalIterations = 1
    
    // Final game
    var mysteriousData:[String] = [""]
    var mysteriousString: String = ""
    var computed = false
    
    // MARK: - Letters game
    
    // Splits the string send by the server to an array of letters
    func splitLetters(of str:String, callback: @escaping ()-> ()) {
        let splittedData = str.components(separatedBy: ":")
        self.collectionViewElements = splittedData
        callback()
    }
    
    // Reset & check if needed to jump to the final screen
    func reset(callback:@escaping (Bool)->()) {
        if self.totalIterations == 2 {
            // Navigate to final view
            callback(true)
        }
        else {
            // One more
            self.clickedCells = 0
            self.totalIterations += 1
            callback(false)
        }
    }
    
    // MARK: - Final game
    
    func sendFinalAnswer(str:String, callback:@escaping ()->()) {
        BLEManager.instance.sendData(data: str.data(using: .utf8)!) { (s) in
            print("⬆️ Sending \(str) to \(s ?? "error")")
            callback()
        }
    }
    
    func computeDistance(callback:@escaping (Int)->()) {
        var distances:[Double] = [0.0]
        
        for element in mysteriousData {
            distances.append(element.distance(between: self.mysteriousString))
        }
        
        if let min = distances.min() {
            if let index = distances.firstIndex(of: min) {
                print("Closest index: " + String(index))
                callback(index)
            }
        }
    }
    
    func processStringFormServer(str:String, callback:@escaping(Bool, Int?)->()) {
        if(!self.computed) {
            self.computed = true
            self.mysteriousString = str
            self.computeDistance() { index in
                callback(true, index)
            }
        }
        else {
            callback(false, nil)
        }
    }
    
    func processFormattedStringFromServer(str:String) {
        // Separate elements in array
        self.mysteriousData = str.components(separatedBy: ":")
        
    }
}
