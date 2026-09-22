//
//  SearchCoordinator.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

@Observable
@MainActor
final class SearchCoordinator {
    let viewModel: SearchViewModel

    private let searchFactory: any SearchFactory

    init(searchFactory: any SearchFactory) {
        self.searchFactory = searchFactory
        viewModel = searchFactory.makeViewModel()
    }

    func makeGenreChartsViewModel(genre: MusicGenre) -> MusicGenreChartsViewModel {
        searchFactory.makeGenreChartsViewModel(genre: genre)
    }

    func makeDetailViewModel(item: MusicItem) -> MusicItemDetailViewModel {
        searchFactory.makeDetailViewModel(item: item)
    }
}
