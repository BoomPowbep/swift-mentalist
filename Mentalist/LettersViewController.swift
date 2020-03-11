//
//  LettersViewController.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import UIKit

class LettersViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var collectionViewElements:[String] = [""]
    var clickedCells: Int = 0
    var totalIterations = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        readFromServer()
    }
    
    func readFromServer() {
        BLEManager.instance.readData { readData in
            let readDataAsString = readData?.stringUTF8
            print("⬇️ Data read from server: \(readDataAsString ?? "error")")
            
            // Separate elements in array
            if let splittedData = readDataAsString?.components(separatedBy: ":") {
                self.collectionViewElements = splittedData
                self.collectionView.reloadData() // Reload
            }
        }
    }
    
    // Explicit
    func resetView() {
        
        if totalIterations == 2 {
            // Navigate to final view
            self.performSegue(withIdentifier: "toFinalScreen", sender: self)
        }
        else {
            self.clickedCells = 0
            self.totalIterations += 1
            readFromServer()
        }
    }
}

extension LettersViewController:UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewElements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "oneCell", for: indexPath) as! LetterCollectionViewCell
        
        cell.letterLabel.text = collectionViewElements[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let letter = collectionViewElements[indexPath.row]
        print("Click on " + letter)
        
        BLEManager.instance.sendData(data: letter.data(using: .utf8)!) { str in
            print("⬆️ Sent \(letter)")
            self.clickedCells += 1
            if self.clickedCells == self.collectionViewElements.count {
                self.resetView()
            }
        }
    }
}


// To make a square cell
extension LettersViewController:UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = UIScreen.main.bounds.width / 2
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
}
