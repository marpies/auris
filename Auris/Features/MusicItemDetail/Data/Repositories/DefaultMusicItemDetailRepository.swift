//
//  DefaultMusicItemDetailRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import MusicKit

struct DefaultMusicItemDetailRepository: MusicItemDetailRepository {
    private static let nextPageLimit = 25

    typealias TrackBatchLoader = (MusicItemCollection<Track>) async throws -> MusicItemCollection<Track>?

    private let musicAuthorizationService: any MusicAuthorizationService
    private let artistPaginationStore: MusicArtistPaginationStore

    init(musicAuthorizationService: any MusicAuthorizationService) {
        self.musicAuthorizationService = musicAuthorizationService
        artistPaginationStore = MusicArtistPaginationStore()
    }

    func load(item: MusicItem) async throws -> MusicItemDetailData {
        guard musicAuthorizationService.currentStatus == .authorized else {
            throw MusicItemDetailError.unavailable
        }

        let requestID = try Self.requestID(for: item)

        do {
            switch item.source {
            case .library:
                return try await loadLibraryDetail(for: item, requestID: requestID)
            case .catalog:
                return try await loadCatalogDetail(for: item, requestID: requestID)
            }
        } catch {
            try Task.checkCancellation()

            guard musicAuthorizationService.currentStatus == .authorized else {
                throw MusicItemDetailError.unavailable
            }

            throw error
        }
    }

    func loadNextPage(cursor: MusicItemDetailPageCursor) async throws -> MusicItemDetailPage {
        guard musicAuthorizationService.currentStatus == .authorized else {
            throw MusicItemDetailError.unavailable
        }

        guard let batch = await artistPaginationStore.takeBatch(cursor: cursor) else {
            throw MusicItemDetailError.unavailable
        }

        do {
            return try await loadNextPage(batch: batch)
        } catch {
            await artistPaginationStore.restore(batch: batch, cursor: cursor)
            try Task.checkCancellation()

            guard musicAuthorizationService.currentStatus == .authorized else {
                throw MusicItemDetailError.unavailable
            }

            throw error
        }
    }

    private func loadLibraryDetail(for item: MusicItem,
                                   requestID: MusicKit.MusicItemID) async throws -> MusicItemDetailData {
        switch item.type {
        case .song:
            var songLibraryRequest = MusicLibraryRequest<Song>()
            songLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let song = try await songLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return Self.makeDetail(from: song, source: item.source)
        case .album:
            var albumLibraryRequest = MusicLibraryRequest<Album>()
            albumLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let album = try await albumLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            let loadedAlbum = try await album.with([.tracks], preferredSource: .library)
            return try await Self.makeDetail(from: loadedAlbum, source: item.source)
        case .artist:
            throw MusicItemDetailError.unavailable
        case .playlist:
            var playlistLibraryRequest = MusicLibraryRequest<Playlist>()
            playlistLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let playlist = try await playlistLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            let loadedPlaylist = try await playlist.with([.tracks], preferredSource: .library)
            return try await Self.makeDetail(from: loadedPlaylist, source: item.source)
        case .radio:
            throw MusicItemDetailError.unavailable
        }
    }

    private func loadCatalogDetail(for item: MusicItem,
                                   requestID: MusicKit.MusicItemID) async throws -> MusicItemDetailData {
        switch item.type {
        case .song:
            let songCatalogRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: requestID)

            guard let song = try await songCatalogRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return Self.makeDetail(from: song)
        case .album:
            var albumCatalogRequest = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: requestID)
            albumCatalogRequest.properties = [.tracks]

            guard let album = try await albumCatalogRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return try await Self.makeDetail(from: album, source: item.source)
        case .artist:
            await artistPaginationStore.reset()

            var request = MusicCatalogResourceRequest<Artist>(matching: \.id, equalTo: requestID)
            request.properties = [
                .latestRelease,
                .topSongs,
                .fullAlbums,
                .singles,
                .appearsOnAlbums,
                .featuredPlaylists,
                .similarArtists
            ]

            guard let artist = try await request.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return await makeDetail(from: artist)
        case .playlist:
            var playlistCatalogRequest = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: requestID)
            playlistCatalogRequest.properties = [.tracks]

            guard let playlist = try await playlistCatalogRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return try await Self.makeDetail(from: playlist, source: item.source)
        case .radio:
            throw MusicItemDetailError.unavailable
        }
    }

    static func requestID(for item: MusicItem) throws -> MusicKit.MusicItemID {
        guard !item.sourceID.isEmpty else {
            throw MusicItemDetailError.unavailable
        }

        return MusicKit.MusicItemID(item.sourceID)
    }

    static func makeDetail(from song: Song, source: MusicItemSource = .catalog) -> MusicItemDetailData {
        .song(makeSong(song, source: source, artworkSize: 900))
    }

    static func makeDetail(from album: Album, source: MusicItemSource = .catalog) async throws -> MusicItemDetailData {
        let songs = try await loadSongs(from: album.tracks, source: source)
        return .album(makeAlbum(album, source: source, artworkSize: 900), songs: songs)
    }

    static func makeDetail(from playlist: Playlist, source: MusicItemSource = .catalog) async throws -> MusicItemDetailData {
        let songs = try await loadSongs(from: playlist.tracks, source: source)
        return .playlist(makePlaylist(playlist, source: source, artworkSize: 900), songs: songs)
    }

    func makeDetail(from artist: Artist) async -> MusicItemDetailData {
        var relationships = MusicArtistRelationships()
        relationships.latestRelease = artist.latestRelease.map { Self.makeAlbum($0) }

        if let collection = artist.topSongs {
            relationships.topSongs = await makePage(collection: collection)
        }

        if let collection = artist.fullAlbums {
            relationships.fullAlbums = await makePage(collection: collection)
        }

        if let collection = artist.singles {
            relationships.singles = await makePage(collection: collection)
        }

        if let collection = artist.appearsOnAlbums {
            relationships.appearsOnAlbums = await makePage(collection: collection)
        }

        if let collection = artist.featuredPlaylists {
            relationships.featuredPlaylists = await makePage(collection: collection)
        }

        if let collection = artist.similarArtists {
            relationships.similarArtists = await makePage(collection: collection)
        }

        return .artist(Self.makeArtist(artist, artworkSize: 1200), relationships: relationships)
    }

    private func loadNextPage(batch: MusicArtistPaginationBatch) async throws -> MusicItemDetailPage {
        switch batch {
        case .songs(let collection):
            let nextCollection = try await collection.nextBatch(limit: Self.nextPageLimit)
            return await makePage(collection: nextCollection)
        case .albums(let collection):
            let nextCollection = try await collection.nextBatch(limit: Self.nextPageLimit)
            return await makePage(collection: nextCollection)
        case .playlists(let collection):
            let nextCollection = try await collection.nextBatch(limit: Self.nextPageLimit)
            return await makePage(collection: nextCollection)
        case .artists(let collection):
            let nextCollection = try await collection.nextBatch(limit: Self.nextPageLimit)
            return await makePage(collection: nextCollection)
        }
    }

    private func makePage(collection: MusicItemCollection<Song>?) async -> MusicItemDetailPage {
        guard let collection else {
            return MusicItemDetailPage(items: [], nextPageCursor: nil)
        }

        let cursor = await artistPaginationStore.register(batch: .songs(collection))
        let items = collection.map { MusicItemMetadata.song(Self.makeSong($0)) }
        return MusicItemDetailPage(items: items, nextPageCursor: cursor)
    }

    private func makePage(collection: MusicItemCollection<Album>?) async -> MusicItemDetailPage {
        guard let collection else {
            return MusicItemDetailPage(items: [], nextPageCursor: nil)
        }

        let cursor = await artistPaginationStore.register(batch: .albums(collection))
        let items = collection.map { MusicItemMetadata.album(Self.makeAlbum($0)) }
        return MusicItemDetailPage(items: items, nextPageCursor: cursor)
    }

    private func makePage(collection: MusicItemCollection<Playlist>?) async -> MusicItemDetailPage {
        guard let collection else {
            return MusicItemDetailPage(items: [], nextPageCursor: nil)
        }

        let cursor = await artistPaginationStore.register(batch: .playlists(collection))
        let items = collection.map { MusicItemMetadata.playlist(Self.makePlaylist($0)) }
        return MusicItemDetailPage(items: items, nextPageCursor: cursor)
    }

    private func makePage(collection: MusicItemCollection<Artist>?) async -> MusicItemDetailPage {
        guard let collection else {
            return MusicItemDetailPage(items: [], nextPageCursor: nil)
        }

        let cursor = await artistPaginationStore.register(batch: .artists(collection))
        let items = collection.map { MusicItemMetadata.artist(Self.makeArtist($0)) }
        return MusicItemDetailPage(items: items, nextPageCursor: cursor)
    }

    static func makeSong(_ song: Song,
                         source: MusicItemSource = .catalog,
                         artworkSize: Int = 600) -> MusicSongMetadata {
        MusicSongMetadata(sourceID: song.id.rawValue,
                          source: source,
                          title: song.title,
                          artistName: song.artistName,
                          albumTitle: song.albumTitle,
                          duration: song.duration,
                          imageURL: song.artwork?.url(width: artworkSize, height: artworkSize))
    }

    private static func makeAlbum(_ album: Album,
                                  source: MusicItemSource = .catalog,
                                  artworkSize: Int = 600) -> MusicAlbumMetadata {
        MusicAlbumMetadata(sourceID: album.id.rawValue,
                           source: source,
                           title: album.title,
                           artistName: album.artistName,
                           trackCount: album.trackCount,
                           imageURL: album.artwork?.url(width: artworkSize, height: artworkSize))
    }

    private static func makePlaylist(_ playlist: Playlist,
                                     source: MusicItemSource = .catalog,
                                     artworkSize: Int = 600) -> MusicPlaylistMetadata {
        MusicPlaylistMetadata(sourceID: playlist.id.rawValue,
                              source: source,
                              name: playlist.name,
                              curatorName: playlist.curatorName,
                              imageURL: playlist.artwork?.url(width: artworkSize, height: artworkSize))
    }

    private static func makeArtist(_ artist: Artist, artworkSize: Int = 600) -> MusicArtistMetadata {
        MusicArtistMetadata(sourceID: artist.id.rawValue,
                            source: .catalog,
                            name: artist.name,
                            genreNames: artist.genreNames,
                            standardEditorialNotes: artist.editorialNotes?.standard,
                            shortEditorialNotes: artist.editorialNotes?.short,
                            imageURL: artist.artwork?.url(width: artworkSize, height: artworkSize))
    }

    static func loadSongs(from tracks: MusicItemCollection<Track>?,
                          source: MusicItemSource = .catalog) async throws -> [MusicSongMetadata] {
        try await loadSongs(from: tracks, source: source, trackBatchLoader: nextBatch)
    }

    static func loadSongs(from tracks: MusicItemCollection<Track>?,
                          source: MusicItemSource = .catalog,
                          trackBatchLoader: TrackBatchLoader) async throws -> [MusicSongMetadata] {
        var trackBatch = tracks
        var songs: [MusicSongMetadata] = []

        while let currentTrackBatch = trackBatch {
            try Task.checkCancellation()

            songs.append(contentsOf: currentTrackBatch.compactMap { track in
                guard case .song(let song) = track else { return nil }

                return makeSong(song, source: source)
            })
            trackBatch = try await trackBatchLoader(currentTrackBatch)
        }

        return songs
    }

    static func nextBatch(_ collection: MusicItemCollection<Track>) async throws -> MusicItemCollection<Track>? {
        collection.hasNextBatch ? try await collection.nextBatch() : nil
    }
}
