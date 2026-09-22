//
//  SearchFlowView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct SearchFlowView: View {
    private let coordinator: SearchCoordinator

    init(coordinator: SearchCoordinator) {
        self.coordinator = coordinator
    }

    var body: some View {
        NavigationStack {
            SearchView(viewModel: coordinator.viewModel)
                .navigationDestination(for: SearchDestination.self) { destination in
                    switch destination {
                    case .searchResult(let item):
                        let viewModel = coordinator.makeDetailViewModel(item: item)
                        MusicItemDetailView(viewModel: viewModel)
                            .task {
                                await coordinator.viewModel.recordSearchResult(item)
                            }
                    case .recentItem(let item), .genreItem(let item):
                        let viewModel = coordinator.makeDetailViewModel(item: item)
                        MusicItemDetailView(viewModel: viewModel)
                    case .genre(let genre):
                        let viewModel = coordinator.makeGenreChartsViewModel(genre: genre)
                        MusicGenreChartsView(viewModel: viewModel)
                    }
                }
        }
    }
}
