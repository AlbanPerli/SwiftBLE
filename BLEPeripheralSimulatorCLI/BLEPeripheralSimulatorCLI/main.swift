//
//  main.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

let runLoop = CFRunLoopGetCurrent()

let consoleIO = ConsoleIO()
print(CommandLine.arguments)
/*
let broadcast = CBCharacteristicProperties.broadcast.rawValue // 1
let read = CBCharacteristicProperties.read.rawValue // 2
let writeWithoutResponse = CBCharacteristicProperties.writeWithoutResponse.rawValue // 4
let write = CBCharacteristicProperties.write.rawValue // 8
let notify = CBCharacteristicProperties.notify.rawValue // 16
let indicate = CBCharacteristicProperties.indicate.rawValue // 32
let authenticatedSignedWrites = CBCharacteristicProperties.authenticatedSignedWrites.rawValue // 64
let extendedProperties = CBCharacteristicProperties.extendedProperties.rawValue // 128
let notifyEncryptionRequired = CBCharacteristicProperties.notifyEncryptionRequired.rawValue // 256
let indicateEncryptionRequired = CBCharacteristicProperties.indicateEncryptionRequired.rawValue // 512
let r = CBAttributePermissions.readable.rawValue // 1
let r1 = CBAttributePermissions.readEncryptionRequired.rawValue // 4
let w = CBAttributePermissions.writeable.rawValue // 2
let w1 = CBAttributePermissions.writeEncryptionRequired.rawValue // 8
*/


if CommandLine.argc < 2 {
    consoleIO.writeMessage("Missing argument", to: OutputType.error)
    consoleIO.printUsage()
}else{
    
    let periphName = CommandLine.arguments[2]
    print(periphName)
    let jsonFileName = CommandLine.arguments[4]
    print(jsonFileName)
    
    if let jsonGatt = try? String(contentsOfFile: jsonFileName),
        let jsonData = jsonGatt.data(using: String.Encoding.utf8),
        let gattModel = try? JSONDecoder().decode(Gatt.self, from: jsonData) {
        
        let periphGatt = PeripheralGatt(model: gattModel)
        let periph = PeripheralController(config: periphGatt)
        try? periph.turnOn()
        
        let scenarioFileNames = ["AuthScenario.txt"]
        
        for scenarioName in scenarioFileNames {
            if let (uuid,stack) = ScenarioFactory.buildScenarioFromFileNamed(scenarioName){
                let char = periph.serviceControllers.first!.characteristics.filter{ $0.characteristic.uuid.uuidString == uuid }.first! as! StandardCharacteristic
                char.setupScenario(stack)
                char.scenarioDidFinish = { success in
                    if success {
                        print("\(scenarioName) finished")
                    }else{
                        print("\(scenarioName) failed")
                        CFRunLoopStop(runLoop)
                    }
                }
            }else{
                fatalError("Corrupted scenario file.")
            }
        }
        
        print("start")
        CFRunLoopRun()
        //consoleIO.writeMessage("Finished with error", to: OutputType.error)
    }
    
}

