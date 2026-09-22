//
//  SearchResultsView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchResultsView: View {
    let section: MusicSearchResultSection
    let recordsRecentSelection: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(section.items) { item in
                NavigationLink(value: destination(for: item)) {
                    SearchMusicItemRowView(item: item, sourceDescription: nil)
                }
                .buttonStyle(.plain)

                if item.id != section.items.last?.id {
                    Divider()
                        .padding(.leading, 68)
                }
            }
        }
    }

    private func destination(for item: MusicItem) -> SearchDestination {
        recordsRecentSelection ? .searchResult(item) : .genreItem(item)
    }
}
