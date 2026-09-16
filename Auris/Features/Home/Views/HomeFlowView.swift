//
//  HomeFlowView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SwiftUI

struct HomeFlowView: View {
    private let coordinator: HomeCoordinator

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        NavigationStack {
            HomeView(viewModel: coordinator.viewModel)
                .navigationDestination(for: MusicItem.self) { item in
                    MusicItemDetailView(viewModel: coordinator.makeDetailViewModel(item: item))
                }
        }
    }
}
