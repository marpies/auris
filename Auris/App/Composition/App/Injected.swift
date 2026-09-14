//
//  Injected.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

/// A property wrapper that resolves an instance once lazily.
@propertyWrapper
struct Injected<T> {
    private let resolverProvider: ResolverProvider
    
    lazy var wrappedValue: T = {
        resolverProvider.resolve(T.self)
    }()
    
    init(resolverProvider: ResolverProvider) {
        self.resolverProvider = resolverProvider
    }
}

/// A property wrapper that resolves an instance on every access.
@propertyWrapper
struct InjectedGetter<T> {
    private let resolverProvider: ResolverProvider
    
    var wrappedValue: T {
        resolverProvider.resolve(T.self)
    }
    
    init(resolverProvider: ResolverProvider) {
        self.resolverProvider = resolverProvider
    }
}
