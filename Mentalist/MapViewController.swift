//
//  MapViewController.swift
//  Mentalist
//
//  Created by Mickaël Debalme on 11/03/2020.
//  Copyright © 2020 Mickael Debalme. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    private let locationManager = LocationManager()
    
    var cities:[String] = [""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func onReadButtonClicked(_ sender: Any) {
        BLEManager.instance.readMapData { (cityName) in
            if let cityNameAsString = cityName?.stringUTF8 {
                
                if !self.cities.contains(cityNameAsString) {
                    print("🗺 Adding \(cityNameAsString) to the map")
                    self.cities.append(cityNameAsString)
                    self.locationManager.getLocation(forPlaceCalled: cityNameAsString) { (location) in
                        if let loc = location {
                            self.addMarker(for: loc)
                        }
                    }
                }
                else {
                    print("\(cityNameAsString) already on the map")
                }
            }
        }
    }
    
    func addMarker(for location:CLLocation) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate
        map.addAnnotation(annotation)
    }
    
}
