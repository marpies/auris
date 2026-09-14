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
        VStack {
            Text("Hello Home")
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
    
    let viewModel = HomeViewModel(homeContentRepository: MockHomeContentRepository())
    return HomeView(viewModel: viewModel)
}
