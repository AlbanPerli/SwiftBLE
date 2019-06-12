//
//  ScenarioManager.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 10/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation

class ScenarioManager {
    static let instance = ScenarioManager()
    
    var currentChars = [StandardCharacteristic]()
    
    func setupWithPeripheral(_ peripheral:PeripheralController)  {
        currentChars = peripheral.standardChars
    }
    
    func setupCharsWithScenarioFilePaths(_ scenarioFileNames:[String]) {
        for scenarioName in scenarioFileNames {
            if let scenario = ScenarioFactory.buildScenarioFromFileNamed(scenarioName){
                let char = currentChars.filter{ $0.characteristic.uuid.uuidString == scenario.charUUID }.first!
                char.setupScenario(scenario)
            }
        }
    }
    
}
