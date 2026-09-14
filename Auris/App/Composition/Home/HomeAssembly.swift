//
//  HomeAssembly.swift
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

struct HomeAssembly: SafeAssembly {
    func assemble(container: Container, resolverProvider: any ResolverProvider) {
        container.register((any HomeFactory).self) { _ in
            return DefaultHomeFactory(resolver: resolverProvider)
        }
        container.register((any HomeContentRepository).self) { _ in
            return DefaultHomeContentRepository()
        }
        container.register(HomeViewModel.self) { _ in
            let repository = resolverProvider.resolve((any HomeContentRepository).self)
            return HomeViewModel(homeContentRepository: repository)
        }
    }
}
