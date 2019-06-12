//
//  PeripheralExtension.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 10/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation

extension PeripheralController {
    
    var standardChars:[StandardCharacteristic] {
        get{
            return self.serviceControllers.compactMap{ $0.characteristics as? [StandardCharacteristic] }.flatMap{ $0 }
        }
    }
    
}
