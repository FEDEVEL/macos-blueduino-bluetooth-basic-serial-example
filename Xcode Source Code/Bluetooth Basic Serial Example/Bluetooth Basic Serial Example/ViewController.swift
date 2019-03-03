//
//  ViewController.swift
//  Bluetooth Basic Serial Example
//
//  Created by Robo on 3/3/19.
//  Copyright © 2019 FEDEVEL. All rights reserved.
//

//Follow this: https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor

import Cocoa
import CoreBluetooth

let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
var blePeripheral : CBPeripheral?

class ViewController: NSViewController {
    
    var centralManager: CBCentralManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
        {
            print("Found!")
            blePeripheral = peripheral
            blePeripheral?.delegate = self
            centralManager?.connect(blePeripheral!, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("I am connected!")
        blePeripheral?.discoverServices(nil)
    }

}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            print(service)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
        }
    }
}



