//
//  LoggerLevel.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

enum LoggerLevel: UInt8 {
    case critical = 4
    case debug = 0
    case error = 3
    case info = 1
    case warning = 2
    
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue <= rhs.rawValue
    }
}
