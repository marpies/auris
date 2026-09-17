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
                if viewModel.item.type == .artist {
                    MusicArtistDetailHeaderView(title: detail?.title ?? viewModel.item.title,
                                                subtitle: subtitle,
                                                imageURL: detail?.imageURL ?? viewModel.item.imageURL)
                } else {
                    MusicItemDetailHeaderView(title: detail?.title ?? viewModel.item.title,
                                              subtitle: subtitle,
                                              imageURL: detail?.imageURL ?? viewModel.item.imageURL,
                                              type: viewModel.item.type)
                        .padding(.horizontal)
                        .padding(.top)
                }

                switch viewModel.state {
                case .loading:
                    ProgressView("Loading details…")
                        .padding(.horizontal)
                case .content(let detail):
                    MusicItemDetailContentView(content: detail.content,
                                               loadingSectionIDs: viewModel.loadingSectionIDs,
                                               failedSectionIDs: viewModel.failedSectionIDs,
                                               loadNextPage: viewModel.loadNextPage)
                        .padding(.horizontal, viewModel.item.type == .artist ? 0 : 16)
                case .unavailable:
                    ContentUnavailableView("Music Unavailable",
                                           systemImage: "music.note",
                                           description: Text("This item is no longer available, or access to your music has changed."))
                        .padding(.horizontal)
                case .error:
                    VStack(spacing: 12) {
                        Text("Couldn’t load details.")
                        Button("Try Again", action: retry)
                            .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom)
        }
        .ignoresSafeArea(edges: viewModel.item.type == .artist ? .top : [])
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

#Preview("Artist") {
    let item = MusicItem(sourceID: "1",
                         source: .catalog,
                         type: .artist,
                         title: "Fleetwood Mac",
                         subtitle: "Rock",
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

    func load(item: MusicItem) async throws -> MusicItemDetailData {
        if loading {
            try await Task.sleep(for: .seconds(2))
        }

        if fails {
            throw URLError(.notConnectedToInternet)
        }

        let tracks: [(title: String, duration: TimeInterval)] = [
            ("Dreams", 258),
            ("Second Hand News", 163),
            ("Never Going Back Again", 134),
            ("Don't Stop", 193),
            ("Go Your Own Way", 218),
            ("Songbird", 200),
            ("The Chain", 270),
            ("You Make Loving Fun", 216),
            ("I Don't Want to Know", 195),
            ("Oh Daddy", 236)
        ]
        let songs = tracks.enumerated().map { index, track in
            MusicSongMetadata(sourceID: "preview-song-\(index)",
                              source: item.source,
                              title: track.title,
                              artistName: "Fleetwood Mac",
                              albumTitle: "Rumours",
                              duration: track.duration,
                              imageURL: nil)
        }
        let album = MusicAlbumMetadata(sourceID: "2",
                                       source: item.source,
                                       title: item.type == .album ? item.title : "Rumours",
                                       artistName: "Fleetwood Mac",
                                       trackCount: 11,
                                       imageURL: nil)

        switch item.type {
        case .song:
            return .song(songs[0])
        case .artist:
            let artist = MusicArtistMetadata(sourceID: item.sourceID,
                                             source: item.source,
                                             name: item.title,
                                             genreNames: ["Rock"],
                                             standardEditorialNotes: "A preview biography for the artist.",
                                             shortEditorialNotes: nil,
                                             imageURL: nil)
            var relationships = MusicArtistRelationships()
            relationships.latestRelease = album
            relationships.topSongs = MusicItemDetailPage(items: songs.map(MusicItemMetadata.song), nextPageCursor: nil)
            relationships.fullAlbums = MusicItemDetailPage(items: [.album(album)], nextPageCursor: nil)
            return .artist(artist, relationships: relationships)
        case .album:
            return .album(album, songs: empty ? [] : songs)
        case .playlist:
            let playlist = MusicPlaylistMetadata(sourceID: item.sourceID,
                                                 source: item.source,
                                                 name: item.title,
                                                 curatorName: item.subtitle,
                                                 imageURL: nil)
            return .playlist(playlist, songs: empty ? [] : songs)
        case .radio:
            throw MusicItemDetailError.unavailable
        }
    }

    func loadNextPage(cursor: MusicItemDetailPageCursor) async throws -> MusicItemDetailPage {
        MusicItemDetailPage(items: [], nextPageCursor: nil)
    }
}
#endif
