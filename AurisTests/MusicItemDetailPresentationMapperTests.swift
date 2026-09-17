//
//  MusicItemDetailPresentationMapperTests.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import Testing
@testable import Auris

@MainActor
struct MusicItemDetailPresentationMapperTests {
    private let presentationMapper = MusicItemDetailPresentationMapper()
    private let artistMetadata = MusicArtistMetadata(sourceID: "artist",
                                                     source: .catalog,
                                                     name: "Artist",
                                                     genreNames: ["", "Rock", "Alternative", "Pop"],
                                                     standardEditorialNotes: "",
                                                     shortEditorialNotes: "Short biography",
                                                     imageURL: nil)

    @Test func ordersSectionsAndPreservesPagingWhileOmittingEmptyRelationships() {
        let album = MusicAlbumMetadata(sourceID: "album",
                                       source: .catalog,
                                       title: "Album",
                                       artistName: "Artist",
                                       trackCount: 12,
                                       imageURL: nil)
        let cursor = MusicItemDetailPageCursor()
        let page = MusicItemDetailPage(items: [.album(album)], nextPageCursor: cursor)
        var relationships = MusicArtistRelationships()
        relationships.latestRelease = album
        relationships.fullAlbums = page
        relationships.singles = MusicItemDetailPage(items: [], nextPageCursor: nil)
        relationships.appearsOnAlbums = page
        relationships.similarArtists = MusicItemDetailPage(items: [.artist(artistMetadata)], nextPageCursor: nil)
        let data = MusicItemDetailData.artist(artistMetadata, relationships: relationships)
        let detail = presentationMapper.makeDetail(from: data)

        guard case .artist(let artist) = detail.content else {
            Issue.record("Expected artist presentation")
            return
        }

        #expect(detail.subtitle == "Rock • Alternative")
        #expect(artist.biography == "Short biography")
        #expect(artist.sections.map(\.kind) == [.latestRelease, .albums, .appearsOn, .similarArtists])
        #expect(artist.sections[1].nextPageCursor == cursor)
        #expect(artist.sections[1].items == page.items.map(presentationMapper.makeItem))
        #expect(artist.sections[1].items.first?.subtitle == "Artist • 12 tracks")
        #expect(artist.sections[1].items.first?.source == .catalog)
    }

    @Test func formatsSongCardsAndKeepsRawDurationForSongDetail() {
        let song = MusicSongMetadata(sourceID: "song",
                                     source: .library,
                                     title: "Song",
                                     artistName: "Artist",
                                     albumTitle: nil,
                                     duration: 183,
                                     imageURL: nil)
        let detail = presentationMapper.makeDetail(from: .song(song))
        let item = presentationMapper.makeItem(from: .song(song))

        guard case .song(let presentedSong) = detail.content else {
            Issue.record("Expected song presentation")
            return
        }

        #expect(presentedSong.duration == 183)
        #expect(presentedSong.album == nil)
        #expect(item.subtitle == "Artist • \(presentedSong.formattedDuration ?? "")")
        #expect(item.source == .library)
        #expect(item.sourceID == "song")
    }

    @Test func emptyPlaylistCuratorUsesCardFallbackButNoHeaderSubtitle() {
        let playlist = MusicPlaylistMetadata(sourceID: "playlist",
                                             source: .catalog,
                                             name: "Playlist",
                                             curatorName: "",
                                             imageURL: nil)
        let detail = presentationMapper.makeDetail(from: .playlist(playlist, songs: []))
        let item = presentationMapper.makeItem(from: .playlist(playlist))
        #expect(detail.subtitle == nil)
        #expect(detail.content == .songs([]))
        #expect(item.subtitle == "Playlist")
    }

    @Test func standardBiographyTakesPrecedenceAndEmptyArtistHasNoSections() {
        let artist = MusicArtistMetadata(sourceID: "artist",
                                         source: .catalog,
                                         name: "Artist",
                                         genreNames: nil,
                                         standardEditorialNotes: "Standard",
                                         shortEditorialNotes: "Short",
                                         imageURL: nil)
        let data = MusicItemDetailData.artist(artist, relationships: MusicArtistRelationships())
        let detail = presentationMapper.makeDetail(from: data)
        #expect(detail.subtitle == nil)
        #expect(detail.content == .artist(MusicArtistDetail(biography: "Standard", sections: [])))
        #expect(presentationMapper.makeItem(from: .artist(artist)).subtitle == "Artist")
    }
}
