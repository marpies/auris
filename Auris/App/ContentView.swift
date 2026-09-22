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
    private let libraryCoordinator: LibraryCoordinator
    private let searchCoordinator: SearchCoordinator

    init(homeCoordinator: HomeCoordinator,
         libraryCoordinator: LibraryCoordinator,
         searchCoordinator: SearchCoordinator) {
        self.homeCoordinator = homeCoordinator
        self.libraryCoordinator = libraryCoordinator
        self.searchCoordinator = searchCoordinator
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
            
            LibraryFlowView(coordinator: libraryCoordinator)
                .tabItem {
                    Label("Library", systemImage: "play.square.stack")
                }
            
            SearchFlowView(coordinator: searchCoordinator)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
        }
    }
}
