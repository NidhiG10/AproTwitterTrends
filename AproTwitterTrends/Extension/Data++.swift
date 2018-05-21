//
//  Data++.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 21/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

extension Data {
    
    var rawBytes: [UInt8] {
        return [UInt8](self)
    }
    
    init(bytes: [UInt8]) {
        self.init(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
    
    mutating func append(_ bytes: [UInt8]) {
        self.append(UnsafePointer<UInt8>(bytes), count: bytes.count)
    }
    
}
