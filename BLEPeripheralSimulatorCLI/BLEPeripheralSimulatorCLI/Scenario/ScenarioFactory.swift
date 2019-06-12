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
        case ack="a",read="r",write="w",nextScenario="s"
    }
    
    class func buildScenarioFromFileNamed(_ name:String) -> Scenario? {
        
        if let str = try? String(contentsOfFile: name) {
            
            let components = str.components(separatedBy: "\n").compactMap{ ($0.isEmpty || $0.first == "/") ? nil : $0 }
            if let uuid = components.first {
                let actions = Array(components.dropFirst())
                let (actionList,nextScenarios) = extractActionsAndNextScenariosFrom(actions: actions)
                let finalActionList = Array(actionList.reversed())
                return Scenario(name: name, nextScenarios: nextScenarios, charUUID: uuid, bleActions: Stack<BLEAction>(array: finalActionList))
            }
        }else{
            fatalError("Scenario file named: \(name) not found...")
        }
        
        return nil
    }
    
    
    class func extractActionsAndNextScenariosFrom(actions:[String]) -> ([BLEAction],[String]) {
        var actionList = [BLEAction]()
        var nextScenarios = [String]()
        
        for var actionStr in actions  {
            let letter = String(actionStr[0])
            actionStr = String(actionStr.dropFirst())
            
            if let action = ActionLetter(rawValue: letter) {
                switch action {
                case .read:
                    let bytesPlusLogic = actionStr.components(separatedBy: "?")
                    let values = bytesPlusLogic[0].map{ String($0) }.chunked(into: 2).map{ $0.joined() }
                    let bytes = values.compactMap{ $0.hexaToBytes()?.first }
                    // Could be used for custom reading reactions
                    //let reactions = bytesPlusLogic.count == 2 ? bytesPlusLogic[1].components(separatedBy: ",") : [String]()
                    
                    actionList.append(CentralReadAction(actionToPerform: { (request,periph) in
                        request.value = Data(bytes)
                        periph?.respond(to: request, withResult: .success)
                        return true
                    }))
                case .write:
                    let bytesPlusLogic = actionStr.components(separatedBy: "?")
                    let actions = bytesPlusLogic[0]
                    var conditions:[(Data)->(Bool)] = []
                    var reactions = [String]()
                    reactions = bytesPlusLogic.count == 2 ? bytesPlusLogic[1].components(separatedBy: ",") : [String]()
                    reactions = reactions.isEmpty ? reactions : reactions.map{ $0.appending(".txt") }
                    
                    if actions.contains("|"){
                        let actionComp = actions.components(separatedBy: "|")
                        for action in actionComp {
                            conditions.append(buildConditionFromStr(action))
                        }
                    }else{
                        conditions.append(buildConditionFromStr(actions))
                    }
                    
                    
                    actionList.append(CentralWriteAction(actionToPerform: { (request,periph) in
                        
                        if let d = request.value {
                            if atLeastOneConditionIsTrue(conditions,withData: d) {
                                periph?.respond(to: request, withResult: .success)
                                return true
                            }else{
                                periph?.respond(to: request, withResult: .unlikelyError)
                                ScenarioManager.instance.setupCharsWithScenarioFilePaths(reactions)
                                return false
                            }
                        }else{
                            fatalError("Wrong auth")
                        }
                        
                    }))
                case .ack:
                    actionList.append(AckAction())
                case .nextScenario:
                    nextScenarios = actionStr.components(separatedBy: ",")
                    nextScenarios = nextScenarios.isEmpty ? nextScenarios : nextScenarios.map{ $0.appending(".txt") }
                }
            }
        }
        
        return (actionList,nextScenarios)
    }
    
    
    class func buildConditionFromStr(_ str:String) -> (Data)->(Bool) {
        var condition:(Data)->(Bool)
        
        if let range = str.slice(from: "[", to: "]")
        {
            let comp = range.components(separatedBy: ":")
            let leftValues = comp[0].map{ String($0) }.chunked(into: 2).map{ $0.joined() }
            let leftBytes = leftValues.compactMap{ $0.hexaToBytes()?.first }
            let rightValues = comp[1].map{ String($0) }.chunked(into: 2).map{ $0.joined() }
            let rightBytes = rightValues.compactMap{ $0.hexaToBytes()?.first }
            
            if rightBytes.count != leftBytes.count { fatalError("Wrong bytes range") }
            
            condition = { lh in
                let bytes = [UInt8](lh)
                if rightBytes.count == leftBytes.count
                    && rightBytes.count == bytes.count {
                    
                    switch bytes.count {
                    case 1:
                        return lh.uint8 >= Data(leftBytes).uint8 && lh.uint8 <= Data(rightBytes).uint8
                    case 2:
                        return lh.uint16 >= Data(leftBytes).uint16 && lh.uint16 <= Data(rightBytes).uint16
                    case 4:
                        return lh.uint32 >= Data(leftBytes).uint32 && lh.uint32 <= Data(rightBytes).uint32
                    case 0:
                        return lh.uint64 >= Data(leftBytes).uint64 && lh.uint64 <= Data(rightBytes).uint64
                    default:
                        return false
                    }
                    
                }else{
                    return false
                }
                
            }
        }else{
            let values = str.map{ String($0) }.chunked(into: 2).map{ $0.joined() }
            let bytes = values.compactMap{ $0.hexaToBytes()?.first }
            condition = { lh in lh == Data(bytes) }
        }
        
        return condition
    }
    
    class func atLeastOneConditionIsTrue(_ conditions:[(Data)->(Bool)], withData data:Data) -> Bool {
        let oneIsTrue = (conditions.filter{
            let currentIsTrue = $0(data)
            if !currentIsTrue {
                // Update Scenarios
                
            }
            return currentIsTrue
        }).count >= 1 ? true : false
        
        return oneIsTrue
    }
}
