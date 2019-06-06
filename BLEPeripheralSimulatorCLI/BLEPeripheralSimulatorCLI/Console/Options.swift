//
//  Options.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 05/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation

enum OptionType: String {
    case periphName = "n"
    case jsonGatt = "gatt"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "n": self = .periphName
        case "gatt": self = .jsonGatt
        case "h": self = .help
        default: self = .unknown
        }
    }
}

func getOption(_ option: String) -> (option:OptionType, value: String) {
    return (OptionType(value: option), option)
}
