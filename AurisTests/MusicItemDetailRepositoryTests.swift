//
//  MusicItemDetailRepositoryTests.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import MusicKit
import Testing
@testable import Auris

@MainActor
struct MusicItemDetailRepositoryTests {
    @Test func rejectsUnavailableAuthorizationBeforeRequestingMusic() async {
        for status in [MusicAuthorizationStatus.denied, .restricted, .notDetermined] {
            let musicAuthorizationService = MusicItemDetailTestAuthorizationService(currentStatus: status)
            let musicItemDetailRepository =
                DefaultMusicItemDetailRepository(musicAuthorizationService: musicAuthorizationService)
            let item = Auris.MusicItem(sourceID: "1",
                                       source: .library,
                                       type: .song,
                                       title: "",
                                       subtitle: "",
                                       imageURL: nil)
            await #expect(throws: MusicItemDetailError.self) {
                try await musicItemDetailRepository.load(item: item)
            }
        }
    }

    @Test func createsRequestIDsForLibraryAndCatalogItems() throws {
        for source in [MusicItemSource.library, .catalog] {
            let item = Auris.MusicItem(sourceID: "i.123:456",
                                       source: source,
                                       type: .song,
                                       title: "",
                                       subtitle: "",
                                       imageURL: nil)
            #expect(try DefaultMusicItemDetailRepository.requestID(for: item).rawValue == "i.123:456")
        }
    }

    @Test func rejectsEmptySourceIDs() {
        for source in [MusicItemSource.library, .catalog] {
            let item = Auris.MusicItem(sourceID: "",
                                       source: source,
                                       type: .song,
                                       title: "",
                                       subtitle: "",
                                       imageURL: nil)
            #expect(throws: MusicItemDetailError.self) {
                try DefaultMusicItemDetailRepository.requestID(for: item)
            }
        }
    }

    @Test func createsSourceAndTypeSpecificIdentities() {
        let librarySong = Auris.MusicItem(sourceID: "1",
                                          source: .library,
                                          type: .song,
                                          title: "",
                                          subtitle: "",
                                          imageURL: nil)
        let catalogSong = Auris.MusicItem(sourceID: "1",
                                          source: .catalog,
                                          type: .song,
                                          title: "",
                                          subtitle: "",
                                          imageURL: nil)
        let libraryAlbum = Auris.MusicItem(sourceID: "1",
                                           source: .library,
                                           type: .album,
                                           title: "",
                                           subtitle: "",
                                           imageURL: nil)
        #expect(librarySong.id != catalogSong.id)
        #expect(librarySong.id != libraryAlbum.id)
    }

    @Test func mapsOptionalSongMetadata() throws {
        let song = try makeSong(id: "1", extraAttributes: "")
        let result = DefaultMusicItemDetailRepository.makeSong(song)
        #expect(result.title == "Song 1")
        #expect(result.artistName == "Artist")
        #expect(result.albumTitle == nil)
        #expect(result.duration == nil)

        let complete = try makeSong(id: "2", extraAttributes: #", "albumName": "Album", "durationInMillis": 183000"#)
        let mapped = DefaultMusicItemDetailRepository.makeSong(complete)
        #expect(mapped.albumTitle == "Album")
        #expect(mapped.duration == 183)
    }

    @Test func mapsCatalogSongDetail() throws {
        let song = try makeSong(id: "1", extraAttributes: #", "albumName": "Album""#)
        let detail = DefaultMusicItemDetailRepository.makeDetail(from: song)

        guard case .song(let metadata) = detail else {
            Issue.record("Expected song metadata")
            return
        }

        #expect(metadata.title == "Song 1")
        #expect(metadata.artistName == "Artist")
        #expect(metadata.albumTitle == "Album")
        #expect(metadata.source == .catalog)
    }

    @Test func preservesLibraryIdentityAndRawTrackMetadata() async throws {
        let song = try makeSong(id: "i.local", extraAttributes: #", "durationInMillis": 183000"#)
        let songs = try await DefaultMusicItemDetailRepository.loadSongs(from: [.song(song)], source: .library)
        #expect(songs.first?.sourceID == "i.local")
        #expect(songs.first?.source == .library)
        #expect(songs.first?.duration == 183)
        #expect(songs.first?.albumTitle == nil)
    }

    @Test func mapsCatalogAlbumDetail() async throws {
        let album = try makeAlbum()
        let detail = try await DefaultMusicItemDetailRepository.makeDetail(from: album)

        guard case .album(let metadata, let songs) = detail else {
            Issue.record("Expected album metadata")
            return
        }

        #expect(metadata.title == "Album")
        #expect(metadata.artistName == "Artist")
        #expect(songs.isEmpty)
    }

    @Test func mapsCatalogPlaylistDetail() async throws {
        let playlist = try makePlaylist()
        let detail = try await DefaultMusicItemDetailRepository.makeDetail(from: playlist)

        guard case .playlist(let metadata, let songs) = detail else {
            Issue.record("Expected playlist metadata")
            return
        }

        #expect(metadata.name == "Playlist")
        #expect(metadata.curatorName == "Curator")
        #expect(songs.isEmpty)
    }

    @Test func mapsCatalogArtistDetail() async throws {
        let musicAuthorizationService = MusicItemDetailTestAuthorizationService(currentStatus: .authorized)
        let musicItemDetailRepository =
            DefaultMusicItemDetailRepository(musicAuthorizationService: musicAuthorizationService)
        let artist = try makeArtist()
        let detail = await musicItemDetailRepository.makeDetail(from: artist)

        guard case .artist(let metadata, let relationships) = detail else {
            Issue.record("Expected artist metadata")
            return
        }

        #expect(metadata.name == "Artist")
        #expect(metadata.genreNames == ["Rock", "Alternative"])
        #expect(metadata.standardEditorialNotes == "Biography")
        #expect(metadata.shortEditorialNotes == nil)
        #expect(relationships == MusicArtistRelationships())
    }

    @Test func rejectsLibraryArtistDetails() async {
        let musicAuthorizationService = MusicItemDetailTestAuthorizationService(currentStatus: .authorized)
        let musicItemDetailRepository =
            DefaultMusicItemDetailRepository(musicAuthorizationService: musicAuthorizationService)
        let item = Auris.MusicItem(sourceID: "1",
                                   source: .library,
                                   type: .artist,
                                   title: "Artist",
                                   subtitle: "",
                                   imageURL: nil)
        await #expect(throws: MusicItemDetailError.self) {
            try await musicItemDetailRepository.load(item: item)
        }
    }

    @Test func loadsAllPagesPreservingOrderAndDuplicates() async throws {
        let first = try makeSong(id: "1", extraAttributes: "")
        let second = try makeSong(id: "2", extraAttributes: "")
        var pageRequests = 0
        let songs = try await DefaultMusicItemDetailRepository.loadSongs(from: [.song(first)]) { _ in
            pageRequests += 1
            return pageRequests == 1 ? [.song(second), .song(first)] : nil
        }
        #expect(songs.map(\.title) == ["Song 1", "Song 2", "Song 1"])
        #expect(pageRequests == 2)
    }

    @Test func omitsMusicVideos() async throws {
        let data = Data(#"{"id":"video1","type":"music-videos","attributes":{"name":"Video","artistName":"Artist"}}"#.utf8)
        let video = try JSONDecoder().decode(MusicVideo.self, from: data)
        let song = try makeSong(id: "1", extraAttributes: "")
        let songs = try await DefaultMusicItemDetailRepository.loadSongs(from: [.musicVideo(video), .song(song)])
        #expect(songs.map(\.title) == ["Song 1"])
    }

    @Test func handlesMissingTracks() async throws {
        let songs = try await DefaultMusicItemDetailRepository.loadSongs(from: nil)
        #expect(songs.isEmpty)
    }

    @Test func propagatesLaterPageFailure() async throws {
        let song = try makeSong(id: "1", extraAttributes: "")
        await #expect(throws: URLError.self) {
            try await DefaultMusicItemDetailRepository.loadSongs(from: [.song(song)]) { _ in
                throw URLError(.networkConnectionLost)
            }
        }
    }

    private func makeSong(id: String, extraAttributes: String) throws -> Song {
        let json = """
        {"id":"\(id)","type":"songs","attributes":{"name":"Song \(id)","artistName":"Artist"\(extraAttributes)}}
        """
        return try JSONDecoder().decode(Song.self, from: Data(json.utf8))
    }

    private func makeAlbum() throws -> Album {
        let json = #"{"id":"1","type":"albums","attributes":{"name":"Album","artistName":"Artist","trackCount":0}}"#
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Album.self, from: data)
    }

    private func makePlaylist() throws -> Playlist {
        let json = #"{"id":"1","type":"playlists","attributes":{"name":"Playlist","curatorName":"Curator"}}"#
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Playlist.self, from: data)
    }

    private func makeArtist() throws -> Artist {
        let json = """
        {
            "id": "1",
            "type": "artists",
            "attributes": {
                "name": "Artist",
                "genreNames": ["Rock", "Alternative"],
                "editorialNotes": {
                    "standard": "Biography"
                }
            }
        }
        """
        let data = Data(json.utf8)
        return try JSONDecoder().decode(Artist.self, from: data)
    }
}
