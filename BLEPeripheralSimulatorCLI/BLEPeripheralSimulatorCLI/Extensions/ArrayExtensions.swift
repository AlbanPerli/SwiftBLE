//
//  ArrayExtensions.swift
//  ArrayExtensions
//
//  Created by AL on 15/03/2018.
//  Copyright © 2018 Alban. All rights reserved.
//

import Foundation

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Array where Element == UInt8 {
    var data: Data { return Data(self) }
}

