## Description
This code is used to talk to Bluetooth module which is placed on [BlueDuino board](https://wiki.aprbrother.com/en/BlueDuino_rev2.html). It is a very simple code, which "connects" [Arduino IDE](https://www.arduino.cc/en/Main/Software) serial console with Bluetooth module serial port. 

This way, we can use Arduino IDE console talk directly to the Bluetooth module and we can for example use AT comands to setup the Bluetooth module. This way, we can also send / receive text messages through Bluetooth to MacBook and back to BlueDuino (on MacBook you will need to run the code located inside [Xcode Source Code](../xcode_source_code) directory).

## Setup
### Hardware
- 1x BlueDuino module
- 1x USB cable to connect module to MacBoook (or PC)
- 1x MacBook (or PC) with Arduino IDE

### Software
Install Arduino IDE Editor or setup it up Online and run through browser. Install the required drivers. Then:
1. Start Arduino IDE
2. Select Board: *LiLyPad Arduino USB*
3. Connect BlueDuino board to USB port. IDE should recognize the board.
4. Copy and paste the code from [MultiSerial.ino](MultiSerial.ino) to the IDE
5. Compile the code and upload it to BlueDuino

## Setting Up And Testing Communication With The Bluetooth Module
1. In IDE, go to *Monitor* and use following settings: *Both NL & CR, 9600 baud*
2. Test communication with the module, write for example: `AT+NAME?` and press *SEND*. You should get an answer like this:
    ```
    OK+NAME:ZeroBeacon
    ```

## Talking To Your MacBook Through Bluetooth
1. Download the code inside [Xcode Source Code](../xcode_source_code) and follow the [instructions](../xcode_source_code/readme.md) 
1. Once you start the Xcode example, then in the IDE console you should see something like:

    ```
    OK+CONN
    iOS received:
    ```
    This means, that our MacBook apllication (which we are running in Xcode) has succesfully connected to our BlueDuino board.

2. At this point we can send any messages to our MacBook. Macbook will receive it and then send back. For example, in the serial console write `Hello` and press *SEND*. In the serial console you should see something like this:
    ```
    iOS received: Hello
    ```
    If you see it, then you have setup this example correctly.

## Links And Resources
- [BlueDuino module](https://wiki.aprbrother.com/en/BlueDuino_rev2.html)
- [BlueDuino AT commands](https://wiki.aprbrother.com/en/ZeroBeacon.html)
- Original code download from [here](https://github.com/AprilBrother/BlueDuino-Library/blob/master/examples/hardwareSerialMonitor/hardwareSerialMonitor.ino)
- The code needed for MacBook is located [here](../xcode_source_code)