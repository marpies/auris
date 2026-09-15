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
            }
        }
        .task {
            try? await viewModel.load()
        }
    }
}

#Preview {
    struct MockHomeContentRepository: HomeContentRepository {
        func load() async throws -> HomeContent {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            return .unauth
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
