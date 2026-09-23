//
//  ImageAssembly.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/23/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Nuke
import Swinject

struct ImageAssembly: SafeAssembly {
    func assemble(container: Container, resolverProvider: any ResolverProvider) {
        container.register((any ImageLoading).self) { _ in
            NukeImageLoader(imagePipeline: .shared)
        }
            .inObjectScope(.container)
    }
}
