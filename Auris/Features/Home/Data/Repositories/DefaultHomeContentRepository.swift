//
//  DefaultHomeContentRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import MusicKit

struct DefaultHomeContentRepository: HomeContentRepository {
    private static let requestLimit = 25

    private let musicAuthorizationService: any MusicAuthorizationService

    init(musicAuthorizationService: any MusicAuthorizationService) {
        self.musicAuthorizationService = musicAuthorizationService
    }
    
    func load() async throws -> HomeContent {
        let status = musicAuthorizationService.currentStatus
        
        switch status {
        case .notDetermined:
            return .unauth
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .library(try await loadMusicItems())
        @unknown default:
            return .restricted
        }
    }

    private func loadMusicItems() async throws -> [MusicItem] {
        async let songItems = loadLibraryItems(of: Song.self)
        async let albumItems = loadLibraryItems(of: Album.self)
        async let playlistItems = loadLibraryItems(of: Playlist.self)

        let (songs, albums, playlists) = try await (songItems, albumItems, playlistItems)
        
        log(debug: "Loaded \(songs.count) song(s), \(albums.count) album(s), \(playlists.count) playlist(s), ")

        return songs.map(makeMusicItem)
            + albums.map(makeMusicItem)
            + playlists.map(makeMusicItem)
    }

    private func loadLibraryItems<Item: MusicLibraryRequestable>(of _: Item.Type) async throws -> MusicItemCollection<Item> {
        var request = MusicLibraryRequest<Item>()
        request.limit = Self.requestLimit
        return try await request.response().items
    }

    private func makeMusicItem(from song: Song) -> MusicItem {
        let subtitle: String

        if let duration = song.duration {
            let formattedDuration = Duration.seconds(duration).formatted(
                .units(allowed: [.minutes, .seconds], width: .abbreviated, maximumUnitCount: 2)
            )
            subtitle = "\(song.artistName) • \(formattedDuration)"
        } else {
            subtitle = song.artistName
        }

        return MusicItem(
            id: "song:\(song.id.rawValue)",
            type: .song,
            title: song.title,
            subtitle: subtitle,
            imageURL: song.artwork?.url(width: 600, height: 600)
        )
    }

    private func makeMusicItem(from album: Album) -> MusicItem {
        MusicItem(
            id: "album:\(album.id.rawValue)",
            type: .album,
            title: album.title,
            subtitle: "\(album.artistName) • \(album.trackCount) tracks",
            imageURL: album.artwork?.url(width: 600, height: 600)
        )
    }

    private func makeMusicItem(from playlist: Playlist) -> MusicItem {
        let curatorName = playlist.curatorName.flatMap { name in
            name.isEmpty ? nil : name
        }

        return MusicItem(
            id: "playlist:\(playlist.id.rawValue)",
            type: .playlist,
            title: playlist.name,
            subtitle: curatorName ?? "Playlist",
            imageURL: playlist.artwork?.url(width: 600, height: 600)
        )
    }
}
