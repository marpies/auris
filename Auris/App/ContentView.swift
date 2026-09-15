//
//  ContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct ContentView: View {
    private let homeCoordinator: HomeCoordinator

    init(homeCoordinator: HomeCoordinator) {
        self.homeCoordinator = homeCoordinator
    }
    
    var body: some View {
        TabView {
            HomeFlowView(coordinator: homeCoordinator)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            RadioFlowView()
                .tabItem {
                    Label("Radio", systemImage: "dot.radiowaves.left.and.right")
                }
            
            LibraryFlowView()
                .tabItem {
                    Label("Library", systemImage: "play.square.stack")
                }
            
            SearchFlowView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}
