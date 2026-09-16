//
//  Logger.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

#if DEBUG || STAGING || TEST
struct DebugLogData {
    let date: Date
    let message: String
}

func getDebugLogs() -> [DebugLogData] {
    Logger.logs
}
#endif

final fileprivate class Logger {
    static let tag: String = "Auris"
    
    static var loggerLevel: LoggerLevel = .debug
    static var logNetworking: Bool = true
    
    #if DEBUG || STAGING || TEST
    static let lock: NSLock = NSLock()
    static var logs: [DebugLogData] = []
    #endif
    
    static func log(critical message: @autoclosure () -> String) {
        guard loggerLevel == .critical else { return }
        #if DEBUG || STAGING || TEST
        let msg: String = "🟥 \(message())"
        appendLog(message: msg)
        #if DEBUG || TEST
        print("[\(tag)]", msg)
        #endif
        #endif
    }
    
    static func log(debug message: @autoclosure () -> String) {
        guard loggerLevel == .debug else { return }
        #if DEBUG || STAGING || TEST
        let msg: String = "🔵 \(message())"
        appendLog(message: msg)
        #if DEBUG || TEST
        print("[\(tag)]", msg)
        #endif
        #endif
    }
    
    static func log(error message: @autoclosure () -> String) {
        guard loggerLevel == .error else { return }
        #if DEBUG || STAGING || TEST
        let msg: String = "🔴 \(message())"
        appendLog(message: msg)
        #if DEBUG || TEST
        print("[\(tag)]", msg)
        #endif
        #endif
    }
    
    static func log(info message: @autoclosure () -> String) {
        guard loggerLevel == .info else { return }
        #if DEBUG || STAGING || TEST
        let msg: String = "🟢 \(message())"
        appendLog(message: msg)
        #if DEBUG || TEST
        print("[\(tag)]", msg)
        #endif
        #endif
    }
    
    static func log(warning message: @autoclosure () -> String) {
        guard loggerLevel == .warning else { return }
        #if DEBUG || STAGING || TEST
        let msg: String = "🟡 \(message())"
        appendLog(message: msg)
        #if DEBUG || TEST
        print("[\(tag)]", msg)
        #endif
        #endif
    }
    
    #if DEBUG || STAGING || TEST
    private static func appendLog(message: String) {
        lock.lock()
        logs.append(DebugLogData(date: Date(), message: message))
        lock.unlock()
    }
    #endif
}

//
// MARK: - Log
//

func log(critical message: @autoclosure () -> String) {
    Logger.log(critical: message())
}

func log(debug message: @autoclosure () -> String) {
    Logger.log(debug: message())
}

func log(error: Error) {
    let userInfo: String = (error as NSError).userInfo.description
    Logger.log(error: "\(error.localizedDescription), user info: \(userInfo)")
}

func log(error message: @autoclosure () -> String) {
    Logger.log(error: message())
}

func log(info message: @autoclosure () -> String) {
    Logger.log(info: message())
}

func log(warning message: @autoclosure () -> String) {
    Logger.log(warning: message())
}

func set(loggerLevel: LoggerLevel) {
    Logger.loggerLevel = loggerLevel
}

//
// MARK: - Log + networking
//

func log(request: URLRequest) {
    guard Logger.logNetworking else { return }
    log(debug: formatted(request: request, verbose: Logger.loggerLevel == .debug))
}

func log(data: Data?, response: HTTPURLResponse?, error: Error?) {
    guard Logger.logNetworking else { return }
    log(debug: formatted(data: data, response: response, error: error, verbose: Logger.loggerLevel == .debug))
}

func log(clientError: Error, request: URLRequest) {
    guard Logger.logNetworking else { return }
    log(debug: formatted(clientError: clientError, request: request))
}

fileprivate func formatted(clientError: Error, request: URLRequest) -> String {
    var message: String = "🛑"
    
    if let url = request.url?.absoluteString { message += " '\(url)'" }
    
    message += "\nClient error: \(clientError) = \(clientError.localizedDescription)"
    
    return message
}

fileprivate func formatted(request: URLRequest, verbose: Bool) -> String {
    var message = ""
    
    if let method = request.httpMethod { message += "\(method) " }
    if let url = request.url?.absoluteString { message += "'\(url)'" }
    
    if verbose {
        if let headers = request.allHTTPHeaderFields, headers.count > 0 {
            message += "\nHeaders: [\n" + formatted(headers: headers) + "]"
        }
        
        message += "\nBody: \(formatted(body: request.httpBody))"
    }
    
    return message
}

fileprivate func formatted(data: Data?, response: HTTPURLResponse?, error: Error?, verbose: Bool) -> String {
    var message = ""
    
    if let statusCode = response?.statusCode {
        switch statusCode {
        case 200..<400:
            message += "✅ \(statusCode) "
        case 400...:
            message += "🛑 \(statusCode) "
        default:
            break
        }
    }
    
    if let url = response?.url?.absoluteString { message += "'\(url)'" }
    
    if let headers = response?.allHeaderFields as? [String: String], headers.count > 0, verbose {
        message += "\nHeaders: [\n" + formatted(headers: headers) + "]"
    }
    
    switch (data, error) {
    case let (nil, error) where error != nil:
        message += "\nError: [\n\tReason: \(error!.localizedDescription)\n]"
    case let (data, nil) where data != nil && verbose:
        message += "\nBody: \(formatted(body: data!))"
    default:
        break
    }
    
    return message
}

fileprivate func formatted(response: HTTPURLResponse, verbose: Bool) -> String {
    var message = ""
    
    let statusCode = response.statusCode
    switch statusCode {
    case 200..<400:
        message += "✅ \(statusCode) "
    case 400...:
        message += "🛑 \(statusCode) "
    default:
        break
    }
    
    if let url = response.url?.absoluteString { message += "'\(url)'" }
    
    if let headers = response.allHeaderFields as? [String: String], headers.count > 0, verbose {
        message += "\nHeaders: [\n" + formatted(headers: headers) + "]"
    }
    
    return message
}

fileprivate func formatted(headers: [String: String]) -> String {
    return headers.sorted(by: { $0.key < $1.key })
        .compactMap { key, value in "\t\(key) : \(value)\n" }
        .joined(separator: .empty)
}

fileprivate func formatted(body: Data?) -> String {
    guard let body = body else { return "nil" }
    if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
       let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
       let message = String(data: pretty, encoding: .utf8) {
        return message
    } else if let message = String(data: body, encoding: .utf8) {
        return message
    } else {
        return body.description
    }
}
