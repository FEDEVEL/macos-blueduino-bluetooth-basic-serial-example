## Description
## Setup
### Hardware
### Software
File -> New -> Project
macOS
Cocoa App
Next

Product name: Bluetooth Basic Serial Example
Select team: e.g you can use your account
organization name: FEDEVEL
Organization identifier: com.fedevel
Language: Swift
Use Story Boards: checked
Create document based application: not checked
Use core data: not checked
Include Unit Testes: not checked
Include UI Tests: not checked
Next

Select location
Next

Hit Play button to test the code

You may see: codesign wants to access key "access" in your keychaing. Write your MacBook user password and hit Always Allow button

You may see: [default] Unable to load Info.plist exceptions (eGPUOverrides), you can igore it. You should see empty window.

Click on Capabilities TAB (when top project is selected). Sandbox should be on, check Bluetooth (we will be using bluetooth, so we need to enable access to it)

Double click on ViewController.swift, here will be everything happening.

Based on tutorial at https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor

1. Import the Core Bluetooth framework. Add following at the beginning of the file:
    ```
    import CoreBluetooth
    ```
1. Extend ViewController. Add this after and of ViewController class:
    ```
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
            }
        }
    }
    ```
1. Add this after `class ViewController: NSViewController {`
    ```
    var centralManager: CBCentralManager!
    ```
1. Add this inside `viewDidLoad()`
    ```
    centralManager = CBCentralManager(delegate: self, queue: nil)
    ```
1. Switch on Bluetooth on your MacBook
1. Build and run your code. At this point, you should see, that your code is talking to bluetooth in your MacBook and you should see status of the Bluetooth. This should be output in the Xcode console:
    ```
    central.state is .poweredOn
    ```
    Note: If you are testing this with iOS, you HAVE TO connect a real device (iPhone / iPad). Otherwise you may be getting *XPC connection invalid* error.
1. We are going to scan for bluetooth devices around your MacBook. Add `centralManager.scanForPeripherals(withServices: nil)` into  `case .poweredOn`:
    ```
    case .poweredOn:
    print("central.state is .poweredOn")
    centralManager.scanForPeripherals(withServices: nil)
    }
    ```
    We would like to see what has been found. Add this function into `extension ViewController: CBCentralManagerDelegate {` to print all devices around:
    ```
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
    }
    ```
    You can see something like this:
    ```
    central.state is .poweredOn
    <CBPeripheral: 0x600003504580, identifier = 0933D848-E7A2-4AC1-9F6B-9451C5A66006, name = (null), state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0933D848-E7A2-4AC1-9F6B-9451C5A66006, name = [TV] Samsung 5 Series (49), state = disconnected>
    <CBPeripheral: 0x6000035053f0, identifier = A9A176ED-39B8-4C80-BDE6-6B28AE836290, name = (null), state = disconnected>
    <CBPeripheral: 0x6000035018c0, identifier = A9A176ED-39B8-4C80-BDE6-6B28AE836290, name = ZeroBeacon, state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0090D2CB-3310-49FD-83BE-87573317C480, name = (null), state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0090D2CB-3310-49FD-83BE-87573317C480, name = (null), state = disconnected>
    ```
    Notice our BlueDuine device - it is the bluetooth peripheral with *name = ZeroBeacon*. This is the peripheral which we would like to work with.
1. Add this at the beginning of the file:
    ```
    let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
    ```
    **You need to use UUID of your BlueDuino board. It is important you update the number!** You will find the number in the console output.
    
    Update `func centralManager`:
    ```
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
        {
            print("Found!")
        }
    }
    ```
    Build and Run you application. Check out the console output. After ZeroBeacon is discovered, you should see a message *Found!* At this point, we have our BlueDuino.
1. Now, we would like to connect to our board. Let's do it. Add `var blePeripheral : CBPeripheral?` to the beginning of the file. It should now look like this:
    ```
    import Cocoa
    import CoreBluetooth

    let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
    var blePeripheral : CBPeripheral?

    class ViewController: NSViewController {
    ```
    Modify `if peripheral.identifier.uuidString == ourBLEPeripheral_UUID` into following:
    ```
    if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
    {
        print("Found!")
        blePeripheral = peripheral
        centralManager?.connect(blePeripheral!, options: nil)
    }
    ```
    Add also new function into `extension ViewController: CBCentralManagerDelegate {`:
    ```
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("I am connected!")
    }
    ```
    Build and run your application. In the Xcode console, you should see *I am connected!* Also, in the IDE console you should see *OK+CONN*
1. We are now connected to our BlueDuino board. We are going to discover services which we can use with the board. Add this on the end of the file:
    ```
    extension ViewController: CBPeripheralDelegate {
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            
            for service in services {
                print(service)
            }
        }
    }
    ```
    Modify `func centralManager`
    ```
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("I am connected!")
        blePeripheral?.discoverServices(nil)
    }
    ```
    Also add `blePeripheral?.delegate = self` into `if peripheral.identifier.uuidString == kBLEService_UUID`
    ```
    if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
    {
        print("Found!")
        blePeripheral = peripheral
        blePeripheral?.delegate = self
        centralManager?.connect(blePeripheral!, options: nil)
    }
    ```
1. Finally, we are going to have a look at characteristics of our service. Into `extension ViewController: CBPeripheralDelegate {` add:
    ```
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
        }
    }

    ```   
    Add `peripheral.discoverCharacteristics(nil, for: service)` into:
    ```
    for service in services {
        print(service)
        peripheral.discoverCharacteristics(nil, for: service)
    }
    ```
    Now, in the Xcode console you should see something like:
    ```
    <CBPeripheral: 0x600003505ad0, identifier = A9A176ED-39B8-4C80-BDE6-6B28AE836290, name = ZeroBeacon, state = connecting>
    Found!
    I am connected!
    <CBService: 0x60000177d2c0, isPrimary = NO, UUID = Device Information>
    <CBService: 0x60000177d1c0, isPrimary = NO, UUID = FFF0>
    <CBCharacteristic: 0x60000260e580, UUID = System ID, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260f900, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260f960, UUID = Serial Number String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260f9c0, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fa20, UUID = Hardware Revision String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fa80, UUID = Software Revision String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fae0, UUID = Manufacturer Name String, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fb40, UUID = IEEE Regulatory Certification, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fba0, UUID = PnP ID, properties = 0x2, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fc00, UUID = FFF1, properties = 0x10, value = (null), notifying = NO>
    <CBCharacteristic: 0x60000260fc60, UUID = FFF2, properties = 0xC, value = (null), notifying = NO>
    ```   

## Running The Code
## Links And Resources