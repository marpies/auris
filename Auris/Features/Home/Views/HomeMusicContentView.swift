//
//  HomeMusicContentView.swift
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

struct HomeMusicContentView: View {
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
                    MusicItemView(item: item)
                }
            }
            .padding()
        }
    }
}

#Preview {
    HomeMusicContentView(items: [
        MusicItem(id: "song:1", type: .song, title: "I Bet You Look Good on the Dancefloor", subtitle: "Arctic Monkeys • 3m 38s", imageURL: nil),
        MusicItem(id: "song:2", type: .song, title: "Dreams", subtitle: "Fleetwood Mac • 4m 18s", imageURL: nil),
        MusicItem(id: "song:3", type: .song, title: "Midnight City", subtitle: "M83 • 4m 3s", imageURL: nil),
        MusicItem(id: "song:4", type: .song, title: "Redbone", subtitle: "Childish Gambino • 5m 27s", imageURL: nil),
        MusicItem(id: "album:1", type: .album, title: "AM", subtitle: "Arctic Monkeys • 12 tracks", imageURL: nil),
        MusicItem(id: "album:2", type: .album, title: "Rumours", subtitle: "Fleetwood Mac • 11 tracks", imageURL: nil),
        MusicItem(id: "album:3", type: .album, title: "Random Access Memories", subtitle: "Daft Punk • 13 tracks", imageURL: nil),
        MusicItem(id: "playlist:1", type: .playlist, title: "Morning Focus", subtitle: "Apple Music", imageURL: nil),
        MusicItem(id: "playlist:2", type: .playlist, title: "Late Night Drive", subtitle: "Apple Music", imageURL: nil),
        MusicItem(id: "playlist:3", type: .playlist, title: "Discover Mix", subtitle: "Apple Music", imageURL: nil)
    ])
}
