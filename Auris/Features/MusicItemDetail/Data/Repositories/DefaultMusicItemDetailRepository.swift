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
    typealias TrackBatchLoader = (MusicItemCollection<Track>) async throws -> MusicItemCollection<Track>?

    let musicAuthorizationService: any MusicAuthorizationService

    func load(item: MusicItem) async throws -> MusicItemDetail {
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

    private func loadLibraryDetail(for item: MusicItem,
                                   requestID: MusicKit.MusicItemID) async throws -> MusicItemDetail {
        switch item.type {
        case .song:
            var songLibraryRequest = MusicLibraryRequest<Song>()
            songLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let song = try await songLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return Self.makeDetail(from: song)
        case .album:
            var albumLibraryRequest = MusicLibraryRequest<Album>()
            albumLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let album = try await albumLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            let loadedAlbum = try await album.with([.tracks], preferredSource: .library)
            return try await Self.makeDetail(from: loadedAlbum)
        case .playlist:
            var playlistLibraryRequest = MusicLibraryRequest<Playlist>()
            playlistLibraryRequest.filter(matching: \.id, equalTo: requestID)

            guard let playlist = try await playlistLibraryRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            let loadedPlaylist = try await playlist.with([.tracks], preferredSource: .library)
            return try await Self.makeDetail(from: loadedPlaylist)
        case .radio:
            throw MusicItemDetailError.unavailable
        }
    }

    private func loadCatalogDetail(for item: MusicItem,
                                   requestID: MusicKit.MusicItemID) async throws -> MusicItemDetail {
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

            return try await Self.makeDetail(from: album)
        case .playlist:
            var playlistCatalogRequest = MusicCatalogResourceRequest<Playlist>(matching: \.id, equalTo: requestID)
            playlistCatalogRequest.properties = [.tracks]

            guard let playlist = try await playlistCatalogRequest.response().items.first else {
                throw MusicItemDetailError.unavailable
            }

            return try await Self.makeDetail(from: playlist)
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

    static func makeDetail(from song: Song) -> MusicItemDetail {
        MusicItemDetail(title: song.title,
                        subtitle: song.artistName,
                        imageURL: song.artwork?.url(width: 900, height: 900),
                        content: .song(makeSong(song)))
    }

    static func makeDetail(from album: Album) async throws -> MusicItemDetail {
        let songs = try await loadSongs(from: album.tracks)
        return MusicItemDetail(title: album.title,
                               subtitle: album.artistName,
                               imageURL: album.artwork?.url(width: 900, height: 900),
                               content: .songs(songs))
    }

    static func makeDetail(from playlist: Playlist) async throws -> MusicItemDetail {
        let subtitle = playlist.curatorName.flatMap { $0.isEmpty ? nil : $0 }
        let songs = try await loadSongs(from: playlist.tracks)
        return MusicItemDetail(title: playlist.name,
                               subtitle: subtitle,
                               imageURL: playlist.artwork?.url(width: 900, height: 900),
                               content: .songs(songs))
    }

    static func makeSong(_ song: Song) -> MusicItemSong {
        MusicItemSong(title: song.title,
                      artist: song.artistName,
                      album: song.albumTitle,
                      duration: song.duration)
    }

    static func loadSongs(from tracks: MusicItemCollection<Track>?) async throws -> [MusicItemSong] {
        try await loadSongs(from: tracks, trackBatchLoader: nextBatch)
    }

    static func loadSongs(from tracks: MusicItemCollection<Track>?,
                          trackBatchLoader: TrackBatchLoader) async throws -> [MusicItemSong] {
        var trackBatch = tracks
        var songs: [MusicItemSong] = []

        while let currentTrackBatch = trackBatch {
            try Task.checkCancellation()

            songs.append(contentsOf: currentTrackBatch.compactMap { track in
                guard case .song(let song) = track else { return nil }

                return makeSong(song)
            })
            trackBatch = try await trackBatchLoader(currentTrackBatch)
        }

        return songs
    }

    static func nextBatch(_ collection: MusicItemCollection<Track>) async throws -> MusicItemCollection<Track>? {
        collection.hasNextBatch ? try await collection.nextBatch() : nil
    }
}
