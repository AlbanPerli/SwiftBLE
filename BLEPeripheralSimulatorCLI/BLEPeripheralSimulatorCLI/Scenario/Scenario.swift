//
//  Scenario.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BLEAction {
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) -> Bool?
    typealias BLEActionCallBack = (CBATTRequest, CBPeripheralManager?)->(Bool)
}

final class UpdateCharValueAction: BLEAction {
    var updateData:Data?
    required init(data: Data) {
        self.updateData = data
    }
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) -> Bool? {
        peripheral?.updateValue(updateData!, for: request!.characteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil)
        return nil
    }
}

final class AckAction: BLEAction {
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) -> Bool? {
        guard let r = request,
            let p = peripheral else {
            fatalError("Request")
        }
        p.respond(to: r, withResult: .success)
        return nil
    }
}

final class CentralReadAction: BLEAction {
    var action:BLEActionCallBack?
    
    required init(actionToPerform: (BLEActionCallBack)?) {
        self.action = actionToPerform
    }
    
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) -> Bool? {
        guard let r = request else {
            fatalError("Todo: manage empty Request")
        }
        return action?(r,peripheral)
    }
}

final class CentralWriteAction: BLEAction {
    var action:BLEActionCallBack?
    
    required init(actionToPerform: BLEActionCallBack?) {
        self.action = actionToPerform
    }
    
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) -> Bool? {
        guard let r = request else {
            fatalError("Todo: manage empty Request")
        }
        return action?(r,peripheral)
    }
}

struct Scenario {
    var name:String
    var nextScenarios:[String]
    var charUUID:String
    var bleActions:Stack<BLEAction>
}
