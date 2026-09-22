//
//  SearchView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct SearchView: View {
    @State private var isSearchPresented = false

    private let viewModel: SearchViewModel

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        Group {
            switch viewModel.accessState {
            case .loading:
                ProgressView()
            case .content:
                if isSearchPresented {
                    SearchActiveContentView(viewModel: viewModel,
                                            searchTarget: $viewModel.searchTarget,
                                            section: $viewModel.resultsSection)
                        .scrollDismissesKeyboard(.immediately)
                } else {
                    SearchDefaultContentView(genreState: viewModel.genreState,
                                             retry: viewModel.retryGenres)
                }
            case .unauth, .denied, .restricted:
                SearchAuthorizationContentView(state: viewModel.accessState,
                                               requestAuthorization: viewModel.requestAuthorization)
            }
        }
        .navigationTitle("Search")
        .searchable(text: $viewModel.searchText,
                    isPresented: $isSearchPresented,
                    prompt: "Artists, Songs, Albums, and More")
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    let dependencies = SearchViewModelDependencies(musicSearchRepository: PreviewMusicSearchRepository(),
                                                   recentSearchRepository: PreviewRecentSearchRepository(),
                                                   musicAuthorizationService: PreviewSearchAuthorizationService())
    NavigationStack {
        SearchView(viewModel: SearchViewModel(dependencies: dependencies))
    }
}

#if DEBUG
private struct PreviewMusicSearchRepository: MusicSearchRepository {
    func loadGenres() async throws -> [MusicGenre] {
        [
            MusicGenre(sourceID: "1", name: "Alternative"),
            MusicGenre(sourceID: "2", name: "Electronic"),
            MusicGenre(sourceID: "3", name: "Hip-Hop/Rap"),
            MusicGenre(sourceID: "4", name: "Rock")
        ]
    }

    func search(term: String, target: MusicSearchTarget) async throws -> MusicSearchResults {
        MusicSearchResults(sections: [])
    }

    func loadCharts(genre: MusicGenre) async throws -> MusicSearchResults {
        MusicSearchResults(sections: [])
    }
}

private struct PreviewRecentSearchRepository: RecentSearchRepository {
    func load() async -> [MusicItem] {
        []
    }

    func record(item: MusicItem) async -> [MusicItem] {
        [item]
    }
}

private struct PreviewSearchAuthorizationService: MusicAuthorizationService {
    var currentStatus: MusicAuthorizationStatus = .authorized

    func requestAuthorization() async -> MusicAuthorizationStatus {
        .authorized
    }
}
#endif
