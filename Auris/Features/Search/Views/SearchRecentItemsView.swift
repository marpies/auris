//
//  SearchRecentItemsView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchRecentItemsView: View {
    let items: [MusicItem]

    var body: some View {
        if items.isEmpty {
            ContentUnavailableView("No Recent Searches",
                                   systemImage: "clock",
                                   description: Text("Items you open from search will appear here."))
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("Recently Searched")
                        .font(.title2.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 8)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(items) { item in
                        NavigationLink(value: SearchDestination.recentItem(item)) {
                            SearchMusicItemRowView(item: item,
                                                   sourceDescription: sourceDescription(for: item))
                        }
                        .buttonStyle(.plain)

                        if item.id != items.last?.id {
                            Divider()
                                .padding(.leading, 68)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func sourceDescription(for item: MusicItem) -> String? {
        guard item.source == .library else { return nil }

        switch item.type {
        case .song:
            return "Song from Your Library"
        case .album:
            return "Album from Your Library"
        case .artist:
            return "Artist from Your Library"
        case .playlist:
            return "Playlist from Your Library"
        case .radio:
            return "Radio from Your Library"
        }
    }
}
