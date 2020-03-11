//
//  BLEManager.swift
//  BLEClient
//
//  Created by Sébastien Hernoux on 27/02/2020.
//  Copyright © 2020 Sébastien Hernoux. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject {
    static let instance = BLEManager()
    
    var isBLEEnabled = false
    var isScanning = false
    let s = CBUUID(string: "A14318C7-62FF-484F-81B9-7A4681F47600")
    let readChar = CBUUID(string: "B2DBA4DB-6C7B-4649-A66D-2308B7BB835F")
    let mapChar = CBUUID(string: "9DE0451B-4F87-4677-9FC4-2C81BDF27822")
    let writeChar = CBUUID(string: "39558C62-0EF9-472F-8E38-01F70A07AC55")
    var centralManager: CBCentralManager?
    var connectedPeripherals = [CBPeripheral]()
    var readyPeripherals = [CBPeripheral]()
    
    var scanCallback: ((CBPeripheral,String) -> ())?
    var connectCallback: ((CBPeripheral) -> ())?
    var disconnectCallback: ((CBPeripheral) -> ())?
    var didFinishDiscoveryCallback: ((CBPeripheral) -> ())?
    var globalDisconnectCallback: ((CBPeripheral) -> ())?
    var sendDataCallback: ((String?) -> ())?
    var messageReceivedCallback:((Data?)->())?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func clear() {
        connectedPeripherals = []
        readyPeripherals = []
    }
    
    func scan(callback: @escaping (CBPeripheral,String) -> ()) {
        isScanning = true
        scanCallback = callback
        
        centralManager?.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stopScan() {
        isScanning = false
        centralManager?.stopScan()
    }
    
    func listenForMessages(callback:@escaping(Data?)->()) {
        messageReceivedCallback = callback
    }
    
    func connectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        connectCallback = callback
        centralManager?.connect(periph, options: nil)
    }
    
    func disconnectPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        centralManager?.cancelPeripheralConnection(periph)
    }
    
    func didDisconnectPeripheral(callback: @escaping (CBPeripheral) -> ()) {
        disconnectCallback = callback
        globalDisconnectCallback = callback
    }
    
    func discoverPeripheral(_ periph: CBPeripheral, callback: @escaping (CBPeripheral) -> ()) {
        didFinishDiscoveryCallback = callback
        periph.delegate = self
        periph.discoverServices(nil)
        
    }
    
    func getCharForUUID(_ uuid: CBUUID, forperipheral peripheral: CBPeripheral) -> CBCharacteristic? {
        if let services = peripheral.services {
            for service in services {
                if let characteristics = service.characteristics {
                    for char in characteristics {
                        if char.uuid == uuid {
                            return char
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func sendData(data: Data) {
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(writeChar, forperipheral: periph) {
                periph.writeValue(data, for: char, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    func sendData(data: Data, callback: @escaping (String?) -> ()) {
        sendDataCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(writeChar, forperipheral: periph) {
                periph.writeValue(data, for: char, type: CBCharacteristicWriteType.withResponse)
            }
        }
    }
    
    func readData(callback: @escaping (Data?) -> ()) {
        messageReceivedCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(readChar, forperipheral: periph) {
                periph.readValue(for: char)
            }
        }
    }
    
    func readMapData(callback: @escaping (Data?) -> ()) {
        messageReceivedCallback = callback
        for periph in readyPeripherals {
            if let char = BLEManager.instance.getCharForUUID(mapChar, forperipheral: periph) {
                periph.readValue(for: char)
            }
        }
    }
    
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let services = peripheral.services {
            let count = services.filter { $0.characteristics == nil }.count
            if count == 0 {
                readyPeripherals.append(peripheral)
                didFinishDiscoveryCallback?(peripheral)
            }
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            isBLEEnabled = true
        } else {
            isBLEEnabled = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            scanCallback?(peripheral,localName)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if !connectedPeripherals.contains(peripheral) {
            connectedPeripherals.append(peripheral)
            connectCallback?(peripheral)
        }
    }
        
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripherals.removeAll { $0 == peripheral }
        readyPeripherals.removeAll { $0 == peripheral }
        disconnectCallback?(peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        messageReceivedCallback?(characteristic.value)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        sendDataCallback?(peripheral.name)
    }
    
}


