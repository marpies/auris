//
//  LibraryAssembly.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import Swinject

struct LibraryAssembly: SafeAssembly {
    func assemble(container: Container, resolverProvider: any ResolverProvider) {
        container.register((any LibraryContentRepository).self) { _ in
            return DefaultLibraryContentRepository()
        }
        container.register((any LibraryFactory).self) { _ in
            return DefaultLibraryFactory(resolver: resolverProvider)
        }
        container.register(LibraryViewModel.self) { _ in
            let libraryContentRepository = resolverProvider.resolve((any LibraryContentRepository).self)
            return LibraryViewModel(libraryContentRepository: libraryContentRepository)
        }
    }
}
