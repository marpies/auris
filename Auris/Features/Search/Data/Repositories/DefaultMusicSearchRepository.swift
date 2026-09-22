//
//  DefaultMusicSearchRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import MusicKit

struct DefaultMusicSearchRepository: MusicSearchRepository {
    private static let resultLimit = 10
    private static let genreBatchLimit = 25
    private static let artworkSize = 300

    func loadGenres() async throws -> [MusicGenre] {
        var request = MusicCatalogResourceRequest<Genre>()
        request.limit = Self.genreBatchLimit
        var batch: MusicItemCollection<Genre>? = try await request.response().items
        var genres: [MusicGenre] = []

        while let currentBatch = batch {
            try Task.checkCancellation()

            genres.append(contentsOf: currentBatch.compactMap { genre in
                guard genre.parent != nil else { return nil }

                return MusicGenre(sourceID: genre.id.rawValue, name: genre.name)
            })
            batch = currentBatch.hasNextBatch ? try await currentBatch.nextBatch() : nil
        }

        return Dictionary(grouping: genres, by: \.id)
            .compactMap { $0.value.first }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    func search(term: String, target: MusicSearchTarget) async throws -> MusicSearchResults {
        switch target {
        case .catalog:
            return try await searchCatalog(term: term)
        case .library:
            return try await searchLibrary(term: term)
        }
    }

    func loadCharts(genre: MusicGenre) async throws -> MusicSearchResults {
        let genreID = MusicKit.MusicItemID(genre.sourceID)
        let genreRequest = MusicCatalogResourceRequest<Genre>(matching: \.id, equalTo: genreID)

        guard let catalogGenre = try await genreRequest.response().items.first else {
            return MusicSearchResults(sections: [])
        }

        var request = MusicCatalogChartsRequest(genre: catalogGenre,
                                                types: [Song.self, Album.self, Playlist.self])
        request.limit = Self.resultLimit
        
        let response = try await request.response()
        let songs = response.songCharts.flatMap { $0.items }.map { makeSong($0) }
        let albums = response.albumCharts.flatMap { $0.items }.map { makeAlbum($0) }
        let playlists = response.playlistCharts.flatMap { $0.items }.map { makePlaylist($0) }
        return makeResults(topResults: [], songs: songs, albums: albums, artists: [], playlists: playlists)
    }

    private func searchCatalog(term: String) async throws -> MusicSearchResults {
        var request = MusicCatalogSearchRequest(term: term,
                                                types: [Song.self, Album.self, Artist.self, Playlist.self])
        request.limit = Self.resultLimit
        request.includeTopResults = true
        
        let response = try await request.response()
        return makeResults(topResults: makeTopResults(response.topResults),
                           songs: response.songs.map { makeSong($0) },
                           albums: response.albums.map { makeAlbum($0) },
                           artists: response.artists.map(makeArtist),
                           playlists: response.playlists.map { makePlaylist($0) })
    }

    private func searchLibrary(term: String) async throws -> MusicSearchResults {
        var request = MusicLibrarySearchRequest(term: term,
                                                types: [Song.self, Album.self, Playlist.self])
        request.limit = Self.resultLimit
        request.includeTopResults = true
        
        let response = try await request.response()
        return makeResults(topResults: makeTopResults(response.topResults),
                           songs: response.songs.map { makeSong($0, source: .library) },
                           albums: response.albums.map { makeAlbum($0, source: .library) },
                           artists: [],
                           playlists: response.playlists.map { makePlaylist($0, source: .library) })
    }
    
    private func makeTopResults(_ collection: MusicItemCollection<MusicCatalogSearchResponse.TopResult>) -> [MusicItem] {
        return collection.compactMap { result -> MusicItem? in
            switch result {
            case let .album(album):
                return makeAlbum(album, source: .library)
            case let .playlist(playlist):
                return makePlaylist(playlist, source: .library)
            case let .song(song):
                return makeSong(song, source: .library)
            case let .artist(artist):
                return makeArtist(artist)
            case .musicVideo, .curator, .radioShow, .recordLabel, .station:
                return nil
            @unknown default:
                return nil
            }
        }
    }
    
    private func makeTopResults(_ collection: MusicItemCollection<MusicLibrarySearchResponse.TopResult>) -> [MusicItem] {
        return collection.compactMap { result -> MusicItem? in
            switch result {
            case let .album(album):
                return makeAlbum(album, source: .library)
            case let .playlist(playlist):
                return makePlaylist(playlist, source: .library)
            case let .song(song):
                return makeSong(song, source: .library)
            case .artist, .musicVideo:
                return nil
            @unknown default:
                return nil
            }
        }
    }

    private func makeResults(topResults: [MusicItem],
                             songs: [MusicItem],
                             albums: [MusicItem],
                             artists: [MusicItem],
                             playlists: [MusicItem]) -> MusicSearchResults {
        let candidates: [(MusicSearchResultSectionKind, [MusicItem])] = [
            (.topResults, topResults),
            (.songs, songs),
            (.albums, albums),
            (.artists, artists),
            (.playlists, playlists)
        ]
        let sections = candidates.compactMap { (kind, items) -> MusicSearchResultSection? in
            guard !items.isEmpty else { return nil }

            return MusicSearchResultSection(kind: kind, items: items)
        }
        return MusicSearchResults(sections: sections)
    }

    private func makeSong(_ song: Song, source: MusicItemSource = .catalog) -> MusicItem {
        let subtitle: String

        if let duration = song.duration {
            let formattedDuration = Duration.seconds(duration).formatted(
                .units(allowed: [.minutes, .seconds], width: .abbreviated, maximumUnitCount: 2)
            )
            subtitle = "\(song.artistName) • \(formattedDuration)"
        } else {
            subtitle = song.artistName
        }

        return MusicItem(sourceID: song.id.rawValue,
                         source: source,
                         type: .song,
                         title: song.title,
                         subtitle: subtitle,
                         imageURL: song.artwork?.url(width: Self.artworkSize, height: Self.artworkSize))
    }

    private func makeAlbum(_ album: Album, source: MusicItemSource = .catalog) -> MusicItem {
        MusicItem(sourceID: album.id.rawValue,
                  source: source,
                  type: .album,
                  title: album.title,
                  subtitle: "\(album.artistName) • \(album.trackCount) tracks",
                  imageURL: album.artwork?.url(width: Self.artworkSize, height: Self.artworkSize))
    }

    private func makeArtist(_ artist: Artist) -> MusicItem {
        let genres = (artist.genreNames ?? []).filter { !$0.isEmpty }
        let subtitle = genres.prefix(2).joined(separator: " • ")
        return MusicItem(sourceID: artist.id.rawValue,
                         source: .catalog,
                         type: .artist,
                         title: artist.name,
                         subtitle: subtitle.isEmpty ? "Artist" : subtitle,
                         imageURL: artist.artwork?.url(width: Self.artworkSize, height: Self.artworkSize))
    }

    private func makePlaylist(_ playlist: Playlist, source: MusicItemSource = .catalog) -> MusicItem {
        let curatorName = playlist.curatorName.flatMap { $0.isEmpty ? nil : $0 }
        return MusicItem(sourceID: playlist.id.rawValue,
                         source: source,
                         type: .playlist,
                         title: playlist.name,
                         subtitle: curatorName ?? "Playlist",
                         imageURL: playlist.artwork?.url(width: Self.artworkSize, height: Self.artworkSize))
    }
}
