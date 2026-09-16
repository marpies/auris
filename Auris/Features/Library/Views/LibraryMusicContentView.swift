//
//  LibraryMusicContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SwiftUI

struct LibraryMusicContentView: View {
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 140), spacing: 16)
    ]
    
    private let items: [MusicItem]

    init(items: [MusicItem]) {
        self.items = items
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        MusicItemView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }
}

#Preview {
    LibraryMusicContentView(items: [
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
