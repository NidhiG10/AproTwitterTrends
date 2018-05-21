//
//  Operator++.swift
//  AproTwitterTrends
//
//  Created by Nidhi Goyal on 20/05/18.
//  Copyright © 2018 Nidhi Goyal. All rights reserved.
//

import Foundation

/// If `rhs` is not `nil`, assign it to `lhs`.
infix operator ??= : AssignmentPrecedence // { associativity right precedence 90 assignment } // matches other assignment operators

/// If `rhs` is not `nil`, assign it to `lhs`.
func ??=<T>(lhs: inout T?, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}
