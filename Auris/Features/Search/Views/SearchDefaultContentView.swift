//
//  SearchDefaultContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchDefaultContentView: View {
    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    let genreState: SearchGenreState
    let retry: () async -> Void

    private var columns: [GridItem] {
        if dynamicTypeSize.isAccessibilitySize {
            return [GridItem(.flexible())]
        }

        return [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
    }

    var body: some View {
        Group {
            switch genreState {
            case .loading:
                ProgressView("Loading genres…")
            case .content(let genres):
                if genres.isEmpty {
                    ContentUnavailableView("No Genres Available", systemImage: "music.note.list")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(genres) { genre in
                                NavigationLink(value: SearchDestination.genre(genre)) {
                                    SearchGenreTileView(genre: genre)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            case .error:
                RetryErrorView(title: "Genres Unavailable",
                               message: "Auris couldn’t load Apple Music genres. You can still use Search.") {
                    await retry()
                }
            }
        }
    }
}
