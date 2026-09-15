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
        container.register((any MusicAuthorizationService).self) { _ in
            return DefaultMusicAuthorizationService()
        }
        container.register((any HomeFactory).self) { _ in
            return DefaultHomeFactory(resolver: resolverProvider)
        }
        container.register((any HomeContentRepository).self) { _ in
            let service = resolverProvider.resolve((any MusicAuthorizationService).self)
            return DefaultHomeContentRepository(musicAuthorizationService: service)
        }
        container.register(HomeViewModel.self) { _ in
            let homeContentRepository = resolverProvider.resolve((any HomeContentRepository).self)
            let musicAuthorizationService = resolverProvider.resolve((any MusicAuthorizationService).self)
            let dependencies = HomeViewModelDependencies(homeContentRepository: homeContentRepository,
                                                         musicAuthorizationService: musicAuthorizationService)
            return HomeViewModel(dependencies: dependencies)
        }
    }
}
