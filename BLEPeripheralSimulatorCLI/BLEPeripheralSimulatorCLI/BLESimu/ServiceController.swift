import CoreBluetooth

public protocol ServiceController {
    init(service: CBMutableService, characteristics:[CharacteristicController])
    var service: CBMutableService { get }
    var characteristics : [CharacteristicController] { get }
    func handleReadRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager)
    func handleWriteRequest(_ request: CBATTRequest, peripheral: CBPeripheralManager)
    func handleSubscribeToCharacteristic(characteristic: CBCharacteristic, on peripheral: CBPeripheralManager)
}
