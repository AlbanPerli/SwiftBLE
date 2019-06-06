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
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?)
    typealias BLEActionCallBack = (CBATTRequest, CBPeripheralManager?)->()
}

final class UpdateCharValueAction: BLEAction {
    var updateData:Data?
    required init(data: Data) {
        self.updateData = data
    }
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) {
        peripheral?.updateValue(updateData!, for: request!.characteristic as! CBMutableCharacteristic, onSubscribedCentrals: nil)
    }
}

final class AckAction: BLEAction {
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) {
        guard let r = request,
            let p = peripheral else {
            fatalError("Request")
        }
        p.respond(to: r, withResult: .success)
    }
}

final class CentralReadAction: BLEAction {
    var action:BLEActionCallBack?
    
    required init(actionToPerform: (BLEActionCallBack)?) {
        self.action = actionToPerform
    }
    
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) {
        guard let r = request else {
            fatalError("Request")
        }
        action?(r,peripheral)
    }
}

final class CentralWriteAction: BLEAction {
    var action:BLEActionCallBack?
    
    required init(actionToPerform: BLEActionCallBack?) {
        self.action = actionToPerform
    }
    
    func performActionFor(request:CBATTRequest?, peripheral:CBPeripheralManager?) {
        guard let r = request else {
            fatalError("Request")
        }
        action?(r,peripheral)
    }
}

struct Scenarii {
 
}

extension Scenarii {
    
    func auth() -> Stack<BLEAction> {
        var actionList = [BLEAction]()
        
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data([UInt8(0x01)])
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
            if let d = request.value {
                if d == Data([UInt8(0x01)]) {
                    periph?.respond(to: request, withResult: .success)
                }
            }else{
                fatalError("Wrong auth")
            }
        }))
        actionList.append(AckAction())
        
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data([UInt8(0x02)])
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data([UInt8(0x03)])
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
            if let d = request.value {
                if d == Data([UInt8(0x03)]) {
                    periph?.respond(to: request, withResult: .success)
                }
            }else{
                fatalError("Wrong auth")
            }
        }))
        
        actionList.append(AckAction())
        
        return Stack(array: actionList.reversed())
    }
    
    func retrieveMotionList() -> Stack<BLEAction> {
        var actionList = [BLEAction]()
        
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data([UInt8(0x00)])
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
            if let d = request.value {
                if d == Data([UInt8(0x01),UInt8(0x02)]) {
                    periph?.respond(to: request, withResult: .success)
                }
            }else{
                fatalError("Wrong format")
            }
        }))
        actionList.append(AckAction())
        
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data(Array(repeating: UInt8(0x01), count: 20))
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
            request.value = Data(Array(repeating: UInt8(0x02), count: 20))
            periph?.respond(to: request, withResult: .success)
        }))
        actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
            if let d = request.value {
                if d == Data([UInt8(0x01),UInt8(0x02)]) {
                    periph?.respond(to: request, withResult: .success)
                }
            }else{
                fatalError("Wrong format")
            }
        }))
        actionList.append(AckAction())
        
        return Stack(array:actionList.reversed())
    }
    
}
