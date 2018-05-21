//
//  Scanner++.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 20/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

extension Scanner {
    #if os(macOS) || os(iOS)
    func scanString(string: String) -> String? {
        var buffer: NSString?
        scanString(string, into: &buffer)
        return buffer as String?
    }
    func scanUpToString(_ string: String) -> String? {
        var buffer: NSString?
        scanUpTo(string, into: &buffer)
        return buffer as String?
    }
    #endif
    
    #if os(Linux)
    var isAtEnd: Bool {
    // This is the same check being done inside NSScanner.swift to
    // determine if the scanner is at the end.
    return scanLocation == string.utf16.count
    }
    #endif
}
