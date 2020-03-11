//
//  FinalViewController.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import UIKit

class FinalViewController: UIViewController {
    
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
            
            if let str = readDataAsString {
                MentalistManager.instance.processFormattedStringFromServer(str: str)
            }
        }
    }
    
    
    func readStringFromServer() {
        BLEManager.instance.readData { readData in
            let readDataAsString = readData?.stringUTF8
            print("⬇️ Data read from server: \(readDataAsString ?? "error")")
        
            if let str = readDataAsString {
                MentalistManager.instance.processStringFormServer(str: str) { (status, index) in
                    if status {
                        if let i = index {
                            self.closestIndexLAbel.text = String(i)
                        }
                    }
                    else {
                        print("Final answer: \(readDataAsString ?? "error")")
                        self.closestIndexLAbel.text = "Final answer: \(readDataAsString ?? "error")"
                    }
                }
            }
        }
    }
    
    
    
    
    
    @IBAction func onHappyButtonClicked(_ sender: Any) {
        MentalistManager.instance.sendFinalAnswer(str: "content") {
            self.readStringFromServer()
        }
    }
    
    
    @IBAction func onUnhappyButtonClicked(_ sender: Any) {
        MentalistManager.instance.sendFinalAnswer(str: "pas content"){
            self.readStringFromServer()
        }
    }
    
    @IBAction func onWhyButtonClicked(_ sender: Any) {
        MentalistManager.instance.sendFinalAnswer(str: "pourquoi j'ai choisi DMII?"){
            self.readStringFromServer()
        }
    }
    
}
