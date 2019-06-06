//
//  PeripheralGATT.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

public struct PeripheralGatt {
    
    var name:String
    var services = [ServiceController]()
    
    init(model:Gatt) {
        self.name = model.peripheralName
        for s in model.services {
            services.append(buildService(s))
        }
    }
    
    func buildService(_ service:Service) -> ServiceController {
        let characteristics:[CharacteristicController] = service.characteristics.map{ buildCharacteristic($0) }
        let service = buildCoreBluetoothService(service)
        return StandardService(service: service, characteristics: characteristics)
    }
 
    func buildCharacteristic(_ characteristic:Characteristic) -> CharacteristicController {
        let char = buildCoreBluetoothCharacteristic(characteristic)
        return
            StandardCharacteristic(characteristic: char)
    }
    
    func buildCoreBluetoothService(_ service:Service) -> CBMutableService {
        return CBMutableService(type: CBUUID(string: service.uuid), primary: service.isPrimary)
    }
    
    func buildCoreBluetoothCharacteristic(_ characteristic:Characteristic) -> CBMutableCharacteristic {
        
        let properties = CBCharacteristicProperties(characteristic.properties.map{ CBCharacteristicProperties(rawValue: UInt($0)) })
        let permissions = CBAttributePermissions(characteristic.permissions.map{ CBAttributePermissions(rawValue: UInt($0)) })
        
        return CBMutableCharacteristic(type: CBUUID(string: characteristic.uuid), properties: properties, value: nil, permissions: permissions)

    }
    
}
