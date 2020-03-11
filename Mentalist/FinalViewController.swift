//
//  FinalViewController.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {

    var mysteriousData:[String] = [""]
    var mysteriousString: String = ""
    
    var computed = false
    
    @IBOutlet weak var closestIndexLAbel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.readFormattedStringFromServer()
        
        let stringToSend = "OK"
        
        BLEManager.instance.sendData(data: stringToSend.data(using: .utf8)!) { (str) in
            print("⬆️ Sending \(stringToSend) to \(str ?? "error")")
            self.readStringFromServer()
        }
    }
    
    func readFormattedStringFromServer() {
        BLEManager.instance.readData { readData in
            let readDataAsString = readData?.stringUTF8
            print("⬇️ Data read from server: \(readDataAsString ?? "error")")
            
            // Separate elements in array
            if let splittedData = readDataAsString?.components(separatedBy: ":") {
                self.mysteriousData = splittedData
            }
        }
    }
    
    
    func readStringFromServer() {
        BLEManager.instance.readData { readData in
            let readDataAsString = readData?.stringUTF8
            print("⬇️ Data read from server: \(readDataAsString ?? "error")")
            
            if(!self.computed) {
                self.computed = true
                self.mysteriousString = readDataAsString ?? "error"
                self.computeDistance()
            }
            else {
                print("Final answer: \(readDataAsString ?? "error")")
                self.closestIndexLAbel.text = "Final answer: \(readDataAsString ?? "error")"
            }
        }
    }
    
    func computeDistance() {
        var distances:[Double] = [0.0]
        
        for element in mysteriousData {
            distances.append(element.distance(between: self.mysteriousString))
        }
        
        if let min = distances.min() {
            if let index = distances.firstIndex(of: min) {
                print("Closest index: " + String(index))
                self.closestIndexLAbel.text = String(index)
                
            }
        }
    }
    
    func sendFinalAnswer(str:String) {
        BLEManager.instance.sendData(data: str.data(using: .utf8)!) { (s) in
            print("⬆️ Sending \(str) to \(s ?? "error")")
            self.readStringFromServer()
        }
    }
    
    @IBAction func onHappyButtonClicked(_ sender: Any) {
        self.sendFinalAnswer(str: "content")
    }
    
    
    @IBAction func onUnhappyButtonClicked(_ sender: Any) {
        self.sendFinalAnswer(str: "pas content")
    }
    
    @IBAction func onWhyButtonClicked(_ sender: Any) {
        self.sendFinalAnswer(str: "pourquoi j'ai choisi DMII?")
    }
    
}
