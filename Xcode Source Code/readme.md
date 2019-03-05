## Description
This is a very simple example of Bluetooth code for Xcode. Together with [BlueDuino Source Code](../BlueDuino%20Source%20Code) you can send text messages between your MacBook and [BlueDuino board](https://wiki.aprbrother.com/en/BlueDuino_rev2.html).
## Setup
### Hardware
- 1x BlueDuino module
- 1x USB cable to connect module to MacBook (or PC)
- 1x MacBook (or PC) with Arduino IDE
### Software
- Xcode
## How To Run This Code
You can simply [download this repository](https://github.com/FEDEVEL/macos-blueduino-bluetooth-basic-serial-example/archive/master.zip) and run the code or you can follow the next chapter to create everything by yourself.
## STEP-BY-STEP writing, running and testing this example
1. Start a new project in xCode. 
    - Do following:
        1. File -> New -> Project
        1. Select: macOS
        1. Select: Cocoa App
        1. Click Next
     - Then, fill up the info:   
        1. Product name: Bluetooth Basic Serial Example
        1. Select team: e.g you can use your account
        1. Organization name: YOUR_ORGANIZATION
        1. Organization identifier: com.your_organization
        1. Language: Swift
        1. Use Story Boards: checked
        1. Create document based application: not checked
        1. Use core data: not checked
        1. Include Unit Testes: not checked
        1. Include UI Tests: not checked
        1. Next
     - Select where you would like to save your project   
        1. Select location
        1. Next

1. Hit *Play* button to test the code. You should see an empty window.

    :bulb: You may see: *codesign wants to access key "access" in your keychaing*. Write your MacBook user password and hit *Always Allow* button.

    :bulb: You may see: *[default] Unable to load Info.plist exceptions (eGPUOverrides)*, you can igore it.

1. Click on Capabilities TAB (when the top project is selected). Sandbox should be switched *ON*, also ***Check* the *Bluetooth* checkbox** (we will be using bluetooth, so we need to enable access to it).

1. Double click on *ViewController.swift*, here will be everything happening.

    The next steps are based on tutorial at https://www.raywenderlich.com/231-core-bluetooth-tutorial-for-ios-heart-rate-monitor

1. Import the Core Bluetooth framework. Add following at the beginning of the file:
    ```swift
    import CoreBluetooth
    ```
1. Extend *ViewController*. Add this after and of *ViewController* class:
    ```swift
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
    ```swift
    var centralManager: CBCentralManager!
    ```
1. Add this inside `viewDidLoad()`
    ```swift
    centralManager = CBCentralManager(delegate: self, queue: nil)
    ```
1. Switch on Bluetooth on your MacBook
1. Build and run your code. At this point, you should see, that your code is talking to bluetooth in your MacBook and you should see status of the Bluetooth. This should be output in the Xcode console:
    ```
    central.state is .poweredOn
    ```
    :bulb: Note: If you are testing this with iOS, you HAVE TO connect a real device (iPhone / iPad). Otherwise you may be getting *XPC connection invalid* error.
1. We are going to scan for bluetooth devices around your MacBook. Add `centralManager.scanForPeripherals(withServices: nil)` into  `case .poweredOn`:
    ```swift
    case .poweredOn:
        print("central.state is .poweredOn")
        centralManager.scanForPeripherals(withServices: nil)
    }
    ```
    We would like to see what has been found. Add this function into `extension ViewController: CBCentralManagerDelegate {` to print all devices around:
    ```swift
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
    }
    ```
    Build and run your code. In the Xcode console, you whould see something like this:
    ```
    central.state is .poweredOn
    <CBPeripheral: 0x600003504580, identifier = 0933D848-E7A2-4AC1-9F6B-9451C5A66006, name = (null), state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0933D848-E7A2-4AC1-9F6B-9451C5A66006, name = [TV] Samsung 5 Series (49), state = disconnected>
    <CBPeripheral: 0x6000035053f0, identifier = A9A176ED-39B8-4C80-BDE6-6B28AE836290, name = (null), state = disconnected>
    <CBPeripheral: 0x6000035018c0, identifier = A9A176ED-39B8-4C80-BDE6-6B28AE836290, name = ZeroBeacon, state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0090D2CB-3310-49FD-83BE-87573317C480, name = (null), state = disconnected>
    <CBPeripheral: 0x600003501a20, identifier = 0090D2CB-3310-49FD-83BE-87573317C480, name = (null), state = disconnected>
    ```
    Notice our BlueDuino device - it is the Bluetooth peripheral with *name = ZeroBeacon*. This is the peripheral which we would like to work with.
1. Add this at the beginning of the file:
    ```swift
    let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
    ```
    :bulb: **You may need to use UUID of your BlueDuino board. Check if you do not need to update the number!** You will find the number in your console output.
    
    Update `func centralManager`:
    ```swift
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print(peripheral)
        if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
        {
            print("Found!")
        }
    }
    ```
    Build and run you application. Check out the console output. After ZeroBeacon is discovered, you should see a message *Found!* At this point, we have found our BlueDuino.
1. Now, we would like to connect to our board. Let's do it. Add `var blePeripheral : CBPeripheral?` to the beginning of the file. It should now look like this:
    ```swift
    import Cocoa
    import CoreBluetooth

    let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
    var blePeripheral : CBPeripheral?

    class ViewController: NSViewController {
    ```
    Modify `if peripheral.identifier.uuidString == ourBLEPeripheral_UUID` into following:
    ```swift
    if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
    {
        print("Found!")
        blePeripheral = peripheral
        centralManager?.connect(blePeripheral!, options: nil)
    }
    ```
    Add also new function into `extension ViewController: CBCentralManagerDelegate {`:
    ```swift
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("I am connected!")
    }
    ```
    Build and run your application. In the Xcode console, you should see *I am connected!* Also, in the IDE console you should see *OK+CONN*
1. We are now connected to our BlueDuino board. We are going to discover services which we can use with the board. Add this at the end of the file:
    ```swift
    extension ViewController: CBPeripheralDelegate {
        func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            guard let services = peripheral.services else { return }
            
            for service in services {
                print(service)
            }
        }
    }
    ```
    Modify `func centralManager`, add `blePeripheral?.discoverServices(nil)`. It should look now like this:
    ```swift
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("I am connected!")
        blePeripheral?.discoverServices(nil)
    }
    ```
    Also add `blePeripheral?.delegate = self` into `if peripheral.identifier.uuidString == kBLEService_UUID`
    ```swift
    if peripheral.identifier.uuidString == ourBLEPeripheral_UUID
    {
        print("Found!")
        blePeripheral = peripheral
        blePeripheral?.delegate = self
        centralManager?.connect(blePeripheral!, options: nil)
    }
    ```
1. Finally, we are going to have a look at characteristics of our service. Into `extension ViewController: CBPeripheralDelegate {` add:
    ```swift
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            print(characteristic)
        }
    }

    ```   
    Add `peripheral.discoverCharacteristics(nil, for: service)` into `for service in services {`:
    ```swift
    for service in services {
        print(service)
        peripheral.discoverCharacteristics(nil, for: service)
    }
    ```
    Build and run. Now, in the Xcode console you should see something like:
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
    What we are interested about [FFF1 anf FFF2 Characteristics](https://wiki.aprbrother.com/en/ZeroBeacon.html). These can be used to send and receive messages between MacBook and BlueDuino.
1. We need to access the values of the characteristics. Add following code into `extension ViewController: CBPeripheralDelegate {`:

    ```swift
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        
        switch characteristic.uuid {
        case CBUUID(string: "FFF1"):
            print("Received")
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    ```
    Now modify `for characteristic in characteristics {` and add `peripheral.readValue(for: characteristic)`. It will look like this:   
    ```swift
    for characteristic in characteristics {
        print(characteristic)
        peripheral.readValue(for: characteristic)
    }
    ```
    Build and run the code. You should see some new info in the console, something like this:
    ```
    Characteristic UUID: FFF1 ... Received
    Unhandled Characteristic UUID: FFF2
    Unhandled Characteristic UUID: System ID
    Unhandled Characteristic UUID: Model Number String
    Unhandled Characteristic UUID: Serial Number String
    Unhandled Characteristic UUID: Firmware Revision String
    Unhandled Characteristic UUID: Hardware Revision String
    Unhandled Characteristic UUID: Software Revision String
    Unhandled Characteristic UUID: Manufacturer Name String
    Unhandled Characteristic UUID: IEEE Regulatory Certification
    Unhandled Characteristic UUID: PnP ID
    ```
    Perfect. We are able to read values of characteristics.        
1. To see what we have received from BlueDuino, add this code `peripheral.setNotifyValue(true, for: characteristic)` into `for characteristic in characteristics {`. The code will now look like this:
    ```swift
    for characteristic in characteristics {
        print(characteristic)
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
    }
    ```
    Build and run the code. Then, go into IDE console and write a message for example *Hello*. Every time, when you press *SEND* in the IDE console, you will see in the Xcode console something like *Characteristic UUID: FFF1 ... Received*.
1. To see what we have received, we need to decode the value. Into `extension ViewController: CBPeripheralDelegate {` add following code:
    ```swift
    func dataReceived(from characteristic: CBCharacteristic) -> String {
        guard let characteristicData = characteristic.value else { return "" }
        
        let byteArray = [UInt8](characteristicData)
    
        if let string = String(bytes: byteArray, encoding: .utf8) {
            return(string)
        }
        else{
            return("")
        }
    }
    ```
    Modify also `switch characteristic.uuid {` . Add `let received = dataReceived(from: characteristic)` and also `print(received)`. It will look now like this:
    ```swift
    switch characteristic.uuid {
    case CBUUID(string: "FFF1"):
        print("Characteristic UUID: FFF1 ... Received")
        let received = dataReceived(from: characteristic)
        print(received)
    default:
        print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
    ```
    Build and run your code. Go to IDE serial console, write *Hello* and press *SEND*. In Xcode console you should see something like:
    ```
    Characteristic UUID: FFF1 ... Received
    Hello
    ```
    Perfect, we can receive messages from our BlueDuino. Now, only what we would like to know is how to send a message from MacBook.
1. To send a message from MacBook through Bluetooth to your BlueDuino add into `extension ViewController: CBPeripheralDelegate {` the following code:
    ```swift
    private func writeData(characteristic: CBCharacteristic, message: String) {
        
        print("Sending back: \(message)")
        
        let msg_string = "MacBook: \(message)\n"
        let msg = msg_string.data(using: String.Encoding.utf8)
        
        blePeripheral?.writeValue(msg!, for: characteristic, type: .withResponse)
    }
    ```
    Now, at the begining of your code add `var bleTX : CBCharacteristic?`. It will look like:
    ```swift
    import Cocoa
    import CoreBluetooth

    let ourBLEPeripheral_UUID = "A9A176ED-39B8-4C80-BDE6-6B28AE836290" //BlueDuino
    var blePeripheral : CBPeripheral?
    var bleTX : CBCharacteristic?
    ```
    We also need to store the characteristic for sending data. Inside `for characteristic in characteristics {` add `if characteristic.uuid == CBUUID(string: "FFF2") {` statement. It will look like this:
    ```swift
    for characteristic in characteristics {
        print(characteristic)
        peripheral.readValue(for: characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
        
        if characteristic.uuid == CBUUID(string: "FFF2") {
            bleTX = characteristic
        }
    }
    ``` 
    Always when we receive something, we will send it back. So, into `switch characteristic.uuid {` add `writeData(characteristic: bleTX!, message: received)`. It will look like this:
    ```swift
    switch characteristic.uuid {
        case CBUUID(string: "FFF1"):
            print("Characteristic UUID: FFF1 ... Received")
            let received = dataReceived(from: characteristic)
            print(received)
            writeData(characteristic: bleTX!, message: received)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
    }
    ```
1. Ready! Build your code and run it. Go into IDE console, write *Hello* and press *SEND*. You immedaitelly should see answer in the IDE console. Something like this:
    ```
    Hello BlueDuino!
    OK+CONN
    MacBook: 
    MacBook: Hello
    ``` 
    The message *MacBook: Hello* was sent from your MacBook over Bluetooth to your BlueDuino. If you go into Xcode console, you should see something like this:
    ```
    Characteristic UUID: FFF1 ... Received
    Hello

    Sending back: Hello
    ```
> :exclamation: **IMPORTANT! There may be limits for maximum number of characters to send / receive. Initially only try to send short messages. If you try to send too long message, the communication may get stuck (if that happen, just re-run the Xcode app or disconnect and connect USB cable with your BlueDuino).**

I hope you found this useful.
