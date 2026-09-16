//
//  DefaultLibraryFactory.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

struct DefaultLibraryFactory: LibraryFactory {
    private let resolver: any ResolverProvider

    init(resolver: any ResolverProvider) {
        self.resolver = resolver
    }
    
    func makeViewModel() -> LibraryViewModel {
        resolver.resolve(LibraryViewModel.self)
    }
    
    func makeDetailViewModel(item: MusicItem) -> MusicItemDetailViewModel {
        resolver.resolve(MusicItemDetailViewModel.self, argument: item)
    }
}
