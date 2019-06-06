//
//  CharacteristicController.swift
//  BLEPeripheral
//
//  Created by AL on 04/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import CoreBluetooth

public protocol CharacteristicController {
    init(characteristic:CBMutableCharacteristic)
    var characteristic: CBMutableCharacteristic { get }
    var peripheral: CBPeripheralManager? { get set }
    func handleReadRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager)
    func handleWriteRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager)
    func handleSubscribeToCharacteristic(on peripheral: CBPeripheralManager)
    func updateCharacteristicWithData(data:Data)
}
