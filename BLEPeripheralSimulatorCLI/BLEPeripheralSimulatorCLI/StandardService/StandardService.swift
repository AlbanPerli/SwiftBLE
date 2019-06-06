//
//  CommonService.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

public class StandardService: ServiceController {
    public let service: CBMutableService
    public let characteristics : [CharacteristicController]
    
    public required init(service: CBMutableService, characteristics: [CharacteristicController]) {
        self.service = service
        self.characteristics = characteristics
        service.characteristics = characteristics.map{ $0.characteristic }
    }
    
    public func handleReadRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager) {
        if let char = characteristics.filter({ $0.characteristic.uuid == request.characteristic.uuid }).first {
            char.handleReadRequest(request, peripheral: peripheral)
        }
    }
    
    public func handleSubscribeToCharacteristic(characteristic: CBCharacteristic, on peripheral: CBPeripheralManager) {
        if let char = characteristics.filter({ $0.characteristic.uuid == characteristic.uuid }).first {
            char.handleSubscribeToCharacteristic(on: peripheral)
        }
    }
    
    public func handleWriteRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager) {
        if let char = characteristics.filter({ $0.characteristic.uuid == request.characteristic.uuid }).first {
            char.handleWriteRequest(request, peripheral: peripheral)
        }
    }
    
}
