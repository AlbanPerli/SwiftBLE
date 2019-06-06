//
//  ScenarioBuilder.swift
//  BLEPeripheralSimulatorCLI
//
//  Created by AL on 06/06/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation

class ScenarioFactory {
    
    enum ActionLetter:String {
        case ack="a",read="r",write="w"
    }
    
    class func buildScenarioFromFileNamed(_ name:String) -> (String, Stack<BLEAction>)? {
        
        if let str = try? String(contentsOfFile: name) {
        
            var loop = false
            let components = str.components(separatedBy: "\n").flatMap{ ($0.isEmpty || $0.first == "/") ? nil : $0 }
            if let uuid = components.first {
                var actionList = [BLEAction]()
                
                for actionStr in components.dropFirst() {
                    if actionStr == "loop" { loop = true }
                    let letter = String(actionStr[0])
                    let values = actionStr.dropFirst().map{ String($0) }.chunked(into: 2).map{ $0.joined() }
                    let bytes = values.compactMap{ $0.hexaToBytes()?.first }

                    if let action = ActionLetter(rawValue: letter) {
                        switch action {
                        case .read:
                            actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
                                request.value = Data(bytes)
                                periph?.respond(to: request, withResult: .success)
                            }))
                        case .write:
                            actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
                                if let d = request.value {
                                    if d == Data(bytes) {
                                        periph?.respond(to: request, withResult: .success)
                                    }else{
                                        periph?.respond(to: request, withResult: .unlikelyError)
                                    }
                                }else{
                                    fatalError("Wrong auth")
                                }
                            }))
                        case .ack:
                            actionList.append(AckAction())
                        }
                    }
                }
                var finalActionList = Array(actionList.reversed())
                // TODO: build a better loop!
                if loop {
                    _ = (0...10000).map{ _ in finalActionList.append(contentsOf: actionList.reversed()) }
                }
                return (uuid,Stack(array: finalActionList))
            }
        }
        
        return nil
        
    }
    
}
