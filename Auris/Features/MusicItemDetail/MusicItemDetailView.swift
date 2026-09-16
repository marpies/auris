//
//  MusicItemDetailView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicItemDetailView: View {
    @State private var viewModel: MusicItemDetailViewModel
    @State private var reloadID = 0

    init(viewModel: MusicItemDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    private var detail: MusicItemDetail? {
        guard case .content(let detail) = viewModel.state else { return nil }
        return detail
    }

    private var subtitle: String? {
        if let detail {
            return detail.subtitle
        }

        return viewModel.item.subtitle
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                MusicItemDetailHeaderView(
                    title: detail?.title ?? viewModel.item.title,
                    subtitle: subtitle,
                    imageURL: detail?.imageURL ?? viewModel.item.imageURL,
                    type: viewModel.item.type
                )

                switch viewModel.state {
                case .loading:
                    ProgressView("Loading details…")
                case .content(let detail):
                    MusicItemDetailContentView(content: detail.content)
                case .unavailable:
                    ContentUnavailableView(
                        "Music Unavailable", systemImage: "music.note",
                        description: Text("This item is no longer available, or access to your music has changed.")
                    )
                case .error:
                    VStack(spacing: 12) {
                        Text("Couldn’t load details.")
                        Button("Try Again", action: retry)
                            .buttonStyle(.bordered)
                    }
                }

            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .task(id: reloadID) {
            await viewModel.load()
        }
    }

    private func retry() {
        reloadID += 1
    }
}

#Preview("Song · Missing artwork") {
    let item = MusicItem(sourceID: "1",
                         source: .library,
                         type: .song,
                         title: "Dreams",
                         subtitle: "Fleetwood Mac",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository())
    NavigationStack {
        MusicItemDetailView(viewModel: viewModel)
    }
}

#Preview("Album") {
    let item = MusicItem(sourceID: "1",
                         source: .catalog,
                         type: .album,
                         title: "Rumours",
                         subtitle: "Fleetwood Mac",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository())
    NavigationStack {
        MusicItemDetailView(viewModel: viewModel)
    }
}

#Preview("Playlist · Large text") {
    let item = MusicItem(sourceID: "1",
                         source: .library,
                         type: .playlist,
                         title: "A Long Playlist Title for a Late Night Drive",
                         subtitle: "Marpies",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository())
    NavigationStack {
        MusicItemDetailView(viewModel: viewModel)
    }
    .environment(\.dynamicTypeSize, .accessibility3)
}

#Preview("Loading") {
    let item = MusicItem(sourceID: "1",
                         source: .library,
                         type: .album,
                         title: "Rumours",
                         subtitle: "Fleetwood Mac",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository(loading: true))
    MusicItemDetailView(viewModel: viewModel)
}

#Preview("Error") {
    let item = MusicItem(sourceID: "1",
                         source: .catalog,
                         type: .album,
                         title: "Rumours",
                         subtitle: "Fleetwood Mac",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository(fails: true))
    MusicItemDetailView(viewModel: viewModel)
}

#Preview("Empty playlist") {
    let item = MusicItem(sourceID: "1",
                         source: .catalog,
                         type: .playlist,
                         title: "New Playlist",
                         subtitle: "Marpies",
                         imageURL: nil)
    let viewModel = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: PreviewMusicItemDetailRepository(empty: true))
    MusicItemDetailView(viewModel: viewModel)
}

#if DEBUG
import Foundation

struct PreviewMusicItemDetailRepository: MusicItemDetailRepository {
    var fails = false
    var loading = false
    var empty = false

    func load(item: MusicItem) async throws -> MusicItemDetail {
        if loading {
            try await Task.sleep(for: .seconds(2))
        }

        if fails {
            throw URLError(.notConnectedToInternet)
        }

        let song = MusicItemSong(title: "Dreams", artist: "Fleetwood Mac", album: "Rumours", duration: 258)
        return MusicItemDetail(title: item.title,
                               subtitle: item.subtitle,
                               imageURL: nil,
                               content: item.type == .song ? .song(song) : .songs(empty ? [] : [song, song]))
    }
}
#endif
