//
//  AppCompositionRoot.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import Swinject

final class AppCompositionRoot: ResolverProvider {
    static let shared: AppCompositionRoot = AppCompositionRoot()
    
    private let assembler: Assembler
    private let container: Container
    
    lazy var resolver: Resolver = container.synchronize()
    
    private init() {
        container = Container()
        assembler = Assembler(container: container)
    }
    
    func resolve<Service>(_ type: Service.Type) -> Service {
        guard let service = resolver.resolve(type) else {
            preconditionFailure("Missing Swinject registration: \(type)")
        }
        return service
    }

    func resolve<Service, Argument>(_ type: Service.Type, argument: Argument) -> Service {
        guard let service = resolver.resolve(type, argument: argument) else {
            preconditionFailure("Missing Swinject registration: \(type)")
        }
        return service
    }
    
    func register() {
        let assemblies: [SafeAssembly] = [
            ImageAssembly(),
            HomeAssembly(),
            LibraryAssembly(),
            SearchAssembly()
        ]
        
        for assembly in assemblies {
            assembly.assemble(container: container, resolverProvider: self)
        }
    }
    
    func destroy() {
        container.removeAll()
    }
}
