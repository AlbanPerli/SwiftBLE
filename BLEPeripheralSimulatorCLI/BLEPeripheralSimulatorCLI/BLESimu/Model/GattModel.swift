//
//  Gatt.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation

// MARK: - Gatt
struct Gatt: Codable {
    let peripheralName: String
    let services: [Service]
    
    enum CodingKeys: String, CodingKey {
        case peripheralName
        case services = "Services"
    }
}

// MARK: - Service
struct Service: Codable {
    let name, uuid: String
    let isPrimary: Bool
    let characteristics: [Characteristic]
}

// MARK: - Characteristic
struct Characteristic: Codable {
    let name, uuid: String
    let properties, permissions: [Int]
}
