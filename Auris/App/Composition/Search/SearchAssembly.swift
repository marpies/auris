//
//  SearchAssembly.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Swinject

struct SearchAssembly: SafeAssembly {
    func assemble(container: Container, resolverProvider: any ResolverProvider) {
        container.register((any MusicSearchRepository).self) { _ in
            DefaultMusicSearchRepository()
        }
        container.register((any RecentSearchRepository).self) { _ in
            DefaultRecentSearchRepository()
        }
            .inObjectScope(.container)
        container.register((any SearchFactory).self) { _ in
            DefaultSearchFactory(resolver: resolverProvider)
        }
        container.register(SearchViewModel.self) { _ in
            let musicSearchRepository = resolverProvider.resolve((any MusicSearchRepository).self)
            let recentSearchRepository = resolverProvider.resolve((any RecentSearchRepository).self)
            let musicAuthorizationService = resolverProvider.resolve((any MusicAuthorizationService).self)
            let dependencies = SearchViewModelDependencies(musicSearchRepository: musicSearchRepository,
                                                           recentSearchRepository: recentSearchRepository,
                                                           musicAuthorizationService: musicAuthorizationService)
            return SearchViewModel(dependencies: dependencies)
        }
        container.register(MusicGenreChartsViewModel.self) { (_, genre: MusicGenre) in
            let musicSearchRepository = resolverProvider.resolve((any MusicSearchRepository).self)
            return MusicGenreChartsViewModel(genre: genre,
                                             musicSearchRepository: musicSearchRepository)
        }
    }
}
