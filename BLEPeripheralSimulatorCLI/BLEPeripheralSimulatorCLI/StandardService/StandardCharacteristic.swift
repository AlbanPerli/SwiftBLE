//
//  StandardCharacteristic.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

public class StandardCharacteristic: CharacteristicController {
    public var characteristic: CBMutableCharacteristic
    public var peripheral: CBPeripheralManager?
    
    var scenario:Stack<BLEAction>?
    var scenarioDidFinish:((Bool)->())?
    
    required public init(characteristic:CBMutableCharacteristic) {
        self.characteristic = characteristic
    }
    
    public func handleReadRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager) {
        print("Did receive read request on \(self.characteristic.uuid)")
        
        if let currentAction = scenario?.top,
            currentAction is CentralReadAction
                || currentAction is AckAction {
            currentAction.performActionFor(request: request,peripheral: peripheral)
            popScenario()
        }else{
            scenarioDidFinish?(false)
        }
        
    }
    
    public func handleWriteRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager) {
        print("Did receive write request on \(self.characteristic.uuid)\n with value \(request.value ?? Data(repeating: 0, count: 0))")
        
        if let currentAction = scenario?.top,
            currentAction is CentralWriteAction {
            currentAction.performActionFor(request: request,peripheral: peripheral)
            popScenario()
        }else{
            scenarioDidFinish?(false)
        }
        
    }
    
    public func handleSubscribeToCharacteristic(on peripheral: CBPeripheralManager) {
        self.peripheral = peripheral
    }

    public func updateCharacteristicWithData(data:Data) {
        peripheral?.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
    }
    
    func setupScenario(_ scenario:Stack<BLEAction>) {
        self.scenario = scenario
        updateCharValueIfNeeded()
    }
    
    func popScenario() {
        _ = scenario?.pop()
        updateCharValueIfNeeded()
    }
    
    func updateCharValueIfNeeded() {
        if let currentAction = self.scenario?.top,
            currentAction is UpdateCharValueAction {
            currentAction.performActionFor(request: nil,peripheral: self.peripheral)
            _ = scenario?.pop()
        }
        if let s = self.scenario,
            s.isEmpty {
            scenarioDidFinish?(true)
        }
    }

}
