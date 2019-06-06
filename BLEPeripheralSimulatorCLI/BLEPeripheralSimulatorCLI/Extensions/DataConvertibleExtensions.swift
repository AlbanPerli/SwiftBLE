//
//  DataConvertibleExtensions.swift
//  DataConvertibleExtensions
//
//  Created by AL on 09/11/2017.
//  Copyright © 2017 AL. All rights reserved.
//

import Foundation

// Data Extensions:
protocol DataConvertible {
    init(data:Data)
    var data:Data { get }
}

extension DataConvertible {
    init(data:Data) {
        guard data.count == MemoryLayout<Self>.size else {
            fatalError("data size (\(data.count)) != type size (\(MemoryLayout<Self>.size))")
        }
        self = data.withUnsafeBytes { $0.pointee }
    }
    
    public var data:Data {
        var value = self
        return Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
}

extension UInt8:DataConvertible {}
extension UInt16:DataConvertible {}
extension UInt32:DataConvertible {}
extension Int32:DataConvertible {}
extension Int64:DataConvertible {}
extension Double:DataConvertible {}
extension Float:DataConvertible {}


protocol ToUInt8sConvertable {
    var toUInt8s: [UInt8] { get }
    var toUInt8sBigEndian: [UInt8] { get }
}

extension ToUInt8sConvertable {
    func toUInt8Arr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
}



extension UInt16: ToUInt8sConvertable {
    public var toUInt8s: [UInt8] {
        return toUInt8Arr(endian: self.littleEndian,
                         count: MemoryLayout<UInt16>.size)
    }
    public var toUInt8sBigEndian: [UInt8] {
        return toUInt8Arr(endian: self.bigEndian,
                          count: MemoryLayout<UInt16>.size)
    }
}

extension UInt32: ToUInt8sConvertable {
    public var toUInt8s: [UInt8] {
        return toUInt8Arr(endian: self.littleEndian,
                         count: MemoryLayout<UInt32>.size)
    }
    public var toUInt8sBigEndian: [UInt8] {
        return toUInt8Arr(endian: self.bigEndian,
                          count: MemoryLayout<UInt32>.size)
    }
}

extension UInt64: ToUInt8sConvertable {
    public var toUInt8s: [UInt8] {
        return toUInt8Arr(endian: self.littleEndian,
                         count: MemoryLayout<UInt64>.size)
    }
    public var toUInt8sBigEndian: [UInt8] {
        return toUInt8Arr(endian: self.bigEndian,
                          count: MemoryLayout<UInt64>.size)
    }
}

extension UInt: ToUInt8sConvertable {
    public var toUInt8s: [UInt8] {
        return toUInt8Arr(endian: self.littleEndian,
                          count: MemoryLayout<UInt>.size)
    }
    public var toUInt8sBigEndian: [UInt8] {
        return toUInt8Arr(endian: self.bigEndian,
                          count: MemoryLayout<UInt>.size)
    }
}

extension Int: ToUInt8sConvertable {
    public var toUInt8s: [UInt8] {
        return toUInt8Arr(endian: self.littleEndian,
                          count: MemoryLayout<Int>.size)
    }
    public var toUInt8sBigEndian: [UInt8] {
        return toUInt8Arr(endian: self.bigEndian,
                          count: MemoryLayout<Int>.size)
    }
}


protocol ToHexaStringConvertable {
    var toHexaString: String { get }
}

extension Int:ToHexaStringConvertable {
    public var toHexaString: String {
        return self.toUInt8s.reduce("", { $0 + String(format: "%02x", $1)}).uppercased()
    }
}

extension UInt8:ToHexaStringConvertable {
    public var toHexaString: String {
        return String(format: "%02x", self).uppercased()
    }
}

extension UInt:ToHexaStringConvertable {
    public var toHexaString: String {
        return self.toUInt8s.reduce("", { $0 + String(format: "%02x", $1)}).uppercased()
    }
}
extension UInt16:ToHexaStringConvertable {
    public var toHexaString: String {
        return self.toUInt8s.reduce("", { $0 + String(format: "%02x", $1)}).uppercased()
    }
}
extension UInt32:ToHexaStringConvertable {
    public var toHexaString: String {
        return self.toUInt8s.reduce("", { $0 + String(format: "%02x", $1)}).uppercased()
    }
}
extension UInt64:ToHexaStringConvertable {
    public var toHexaString: String {
        return self.toUInt8s.reduce("", { $0 + String(format: "%02x", $1)}).uppercased()
    }
}

extension Data {
    func toHexaString() -> String {
        let bytes = [UInt8](self)
        return bytes.map{ $0.toHexaString }.joined()
    }
}

extension String {
     public func hexaToBytes(bigEndian:Bool = false) -> [UInt8]? {
        var cleanedHexaStr = self.replacingOccurrences(of: "0x", with: "0")
        cleanedHexaStr = cleanedHexaStr.replacingOccurrences(of: "#", with: "")
        if let uintValue = UInt(cleanedHexaStr, radix: 16) {
            if bigEndian {
                return uintValue.toUInt8sBigEndian
            }else{
                return uintValue.toUInt8s
            }
        }else{
            return nil
        }
    }
}

