//
//  ViewController.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    
    let serverName = "Mickael"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.answerTextField.delegate = self
        
        let _ = BLEManager.instance
        connectToServer()
    }
    
    @IBAction func onMapButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "toMapView", sender: self)
    }
    
    // On return press of keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // Send letter to server
        if let msgAsData = answerTextField.text?.data(using: .utf8) {
            BLEManager.instance.sendData(data: msgAsData) { (str) in
                print("Sending \(str ?? "error") to \(self.serverName)")
                
                // Navigate
                self.performSegue(withIdentifier: "toCollectionView", sender: self)
            }
        }
        
        textField.resignFirstResponder() // Close keyboard
        
        return false
    }
    
    
    func connectToServer() {
        delay(3.0) {
            BLEManager.instance.stopScan()
            
            // Do scan
            BLEManager.instance.scan { (periph, localName) in
                print("🎻 Scan -> " + localName)
                ChatPeripherals.instance.availablePeripherals[localName] = periph
            }
            
            delay(3.0) {
                BLEManager.instance.stopScan()
                ChatPeripherals.instance.connectToAll(serverName: self.serverName) { success in
                    if(success) {
                        let validText = "✅ " + self.serverName + " READY"
                        print(validText)
                        self.statusLabel.text = validText
                    }
                    else {
                        let invalidText = "😰 " + self.serverName + " NOT FOUND"
                        print(invalidText)
                        self.statusLabel.text = invalidText
                    }
                }
            }
        }
    }
}
