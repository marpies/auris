//
//  HomeView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct HomeView: View {
    private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case .content(let items):
                HomeMusicContentView(items: items)
            case .denied:
                HomeDeniedView()
            case .restricted:
                HomeRestrictedView()
            case .unauth:
                HomeUnauthView {
                    await viewModel.requestAuthorization()
                }
            case .error:
                HomeErrorView {
                    await viewModel.load()
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    struct MockHomeContentRepository: HomeContentRepository {
        func load() async throws -> HomeContent {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            return .library([
                MusicItem(sourceID: "1",
                          source: .library,
                          type: .song,
                          title: "I Bet You Look Good on the Dancefloor",
                          subtitle: "Arctic Monkeys • 3m 38s",
                          imageURL: nil),
                MusicItem(sourceID: "2",
                          source: .library,
                          type: .song,
                          title: "Dreams",
                          subtitle: "Fleetwood Mac • 4m 18s",
                          imageURL: nil),
                MusicItem(sourceID: "3",
                          source: .library,
                          type: .song,
                          title: "Midnight City",
                          subtitle: "M83 • 4m 3s",
                          imageURL: nil),
                MusicItem(sourceID: "4",
                          source: .library,
                          type: .song,
                          title: "Redbone",
                          subtitle: "Childish Gambino • 5m 27s",
                          imageURL: nil),
                MusicItem(sourceID: "1",
                          source: .library,
                          type: .album,
                          title: "AM",
                          subtitle: "Arctic Monkeys • 12 tracks",
                          imageURL: nil),
                MusicItem(sourceID: "2",
                          source: .library,
                          type: .album,
                          title: "Rumours",
                          subtitle: "Fleetwood Mac • 11 tracks",
                          imageURL: nil),
                MusicItem(sourceID: "3",
                          source: .library,
                          type: .album,
                          title: "Random Access Memories",
                          subtitle: "Daft Punk • 13 tracks",
                          imageURL: nil),
                MusicItem(sourceID: "1",
                          source: .library,
                          type: .playlist,
                          title: "Morning Focus",
                          subtitle: "Apple Music",
                          imageURL: nil),
                MusicItem(sourceID: "2",
                          source: .library,
                          type: .playlist,
                          title: "Late Night Drive",
                          subtitle: "Apple Music",
                          imageURL: nil),
                MusicItem(sourceID: "3",
                          source: .library,
                          type: .playlist,
                          title: "Discover Mix",
                          subtitle: "Apple Music",
                          imageURL: nil)
            ])
        }
    }
    struct MockMusicAuthorizationService: MusicAuthorizationService {
        var currentStatus: MusicAuthorizationStatus = .notDetermined
        
        func requestAuthorization() async -> MusicAuthorizationStatus {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            return .authorized
        }
    }
    let dependencies = HomeViewModelDependencies(homeContentRepository: MockHomeContentRepository(),
                                                 musicAuthorizationService: MockMusicAuthorizationService())
    let viewModel = HomeViewModel(dependencies: dependencies)
    return HomeView(viewModel: viewModel)
}
