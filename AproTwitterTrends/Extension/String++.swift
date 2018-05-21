//
//  String++.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 20/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation
extension String {
    
    func urlEncodedString(_ encodeAll: Bool = false) -> String {
        var allowedCharacterSet: CharacterSet = .urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
        if !encodeAll {
            allowedCharacterSet.insert(charactersIn: "[]")
        }
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)!
    }
    
    var queryStringParameters: Dictionary<String, String> {
        var parameters = Dictionary<String, String>()
        
        let scanner = Scanner(string: self)
        
        var key: String?
        var value: String?
        
        while !scanner.isAtEnd {
            key = scanner.scanUpToString("=")
            _ = scanner.scanString(string: "=")
            
            value = scanner.scanUpToString("&")
            _ = scanner.scanString(string: "&")
            
            if let key = key, let value = value {
                parameters.updateValue(value, forKey: key)
            }
        }
        
        return parameters
    }
}
