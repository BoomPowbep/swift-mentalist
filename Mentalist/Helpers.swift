//
//  Helpers.swift
//  davinci-drone
//
//  Created by Sébastien Hernoux on 04/11/2019.
//  Copyright © 2019 Sébastien Hernoux. All rights reserved.
//
import Foundation
import UIKit

func delay(_ delay: Float, closure:@escaping ()->()) {
    let when = DispatchTime.now() + Double(delay)
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

func drawCircle(radius: Double = 1.0) -> [CGPoint] {
    var stickPositions: [CGPoint] = []
    let center = CGPoint(x: 0, y: 0)

    for i in stride(from: 0, to: 360.0, by: 10) {
        let radian = i * Double.pi / 180
        let x = Double(center.x) + radius * cos(radian)
        let y = Double(center.y) + radius * sin(radian)
        stickPositions.append(CGPoint(x: x, y: y))
    }
    
    // Reset sticks to neutral position
    stickPositions.append(CGPoint(x: radius, y: 0.0))
    stickPositions.append(CGPoint(x: 0.0, y: 0.0))
    
    return stickPositions
}

extension UIViewController {
    func askForDurationAndSpeed(callback: @escaping(Float, Float)->()) {
        let ac = UIAlertController(title: "Fill values", message: nil, preferredStyle: .alert)
        ac.addTextField {(txt) in
            txt.placeholder = "Speed"
        }
        ac.addTextField {(txt) in
            txt.placeholder = "Duration"
        }

        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned ac] _ in
            if let speedText = ac.textFields![0].text,
               let durationText = ac.textFields![1].text,
               let speed = Float(speedText),
               let duration = Float(durationText) {
               callback(speed, duration)
            }
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
    
    func askForDurationAndSpeedAndHeading(callback: @escaping(Float, Float, Float)->()) {
        let ac = UIAlertController(title: "Fill values", message: nil, preferredStyle: .alert)
        ac.addTextField {(txt) in
            txt.placeholder = "Speed"
        }
        ac.addTextField {(txt) in
            txt.placeholder = "Duration"
        }
        
        ac.addTextField {(txt) in
            txt.placeholder = "Heading"
        }

        let submitAction = UIAlertAction(title: "Add", style: .default) { [unowned ac] _ in
            if let speedText = ac.textFields![0].text,
               let durationText = ac.textFields![1].text,
               let headingText = ac.textFields![2].text,
               let speed = Float(speedText),
               let duration = Float(durationText),
               let heading = Float(durationText) {
               callback(speed, duration, heading)
            }
        }

        ac.addAction(submitAction)

        present(ac, animated: true)
    }
}

extension UIImage {
    func cropToBounds(width: Double, height: Double) -> UIImage {
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)

        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        return UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
    }
    
    
    func croppedWithRect(boundingBox: CGRect) -> UIImage? {
        guard let cgImage = self.cgImage?.cropping(to: boundingBox) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (context) in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
    let context = CIContext(options: nil)
    if context != nil {
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    return nil
}



let PORT_NUMBER = 4986

extension String {
    
    /** A representation of the string in DispatchData form */
    var dispatchData: DispatchData {
        let data = self.data(using: .utf8)!
        let dispatchData = data.withUnsafeBytes {
            DispatchData(bytes: UnsafeBufferPointer(start: $0, count: data.count))
        }
        
        return dispatchData
    }
    
}
/** The different types of data to be used with Peertalk */
enum PTType: UInt32 {
    case number = 100
    case image = 101
    case string = 102
}


private func createWeatherObjectWith<T: Decodable>(json: Data, Object:T.Type ,completion: @escaping (_ data: T?, _ error: Error?) -> Void) {
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let weather = try decoder.decode(T.self, from: json)
        return completion(weather, nil)
    } catch let error {
        return completion(nil, error)
    }
}

extension Decodable {
    static func map(JSONString:String) -> Self? {
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Self.self, from: Data(JSONString.utf8))
        } catch let error {
            print(error)
            return nil
        }
    }
}
