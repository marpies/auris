//
//  DefaultSearchFactory.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

struct DefaultSearchFactory: SearchFactory {
    private let resolver: any ResolverProvider

    init(resolver: any ResolverProvider) {
        self.resolver = resolver
    }

    func makeViewModel() -> SearchViewModel {
        resolver.resolve(SearchViewModel.self)
    }

    func makeGenreChartsViewModel(genre: MusicGenre) -> MusicGenreChartsViewModel {
        resolver.resolve(MusicGenreChartsViewModel.self, argument: genre)
    }

    func makeDetailViewModel(item: MusicItem) -> MusicItemDetailViewModel {
        resolver.resolve(MusicItemDetailViewModel.self, argument: item)
    }
}
