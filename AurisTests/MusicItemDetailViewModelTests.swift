//
//  MusicItemDetailViewModelTests.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import Testing
@testable import Auris

@MainActor
struct MusicItemDetailViewModelTests {
    private let item = MusicItem(sourceID: "1",
                                 source: .library,
                                 type: .album,
                                 title: "Album",
                                 subtitle: "Artist",
                                 imageURL: nil)
    private let detail = MusicItemDetail(title: "Album", subtitle: "Artist", imageURL: nil, content: .songs([]))
    private let detailData = MusicItemDetailData.album(MusicAlbumMetadata(sourceID: "1",
                                                                          source: .library,
                                                                          title: "Album",
                                                                          artistName: "Artist",
                                                                          trackCount: 0,
                                                                          imageURL: nil),
                                                        songs: [])

    private let artistMetadata = MusicArtistMetadata(sourceID: "artist",
                                                     source: .catalog,
                                                     name: "Artist",
                                                     genreNames: ["Rock"],
                                                     standardEditorialNotes: nil,
                                                     shortEditorialNotes: nil,
                                                     imageURL: nil)

    @Test func loadsEmptyCollection() async {
        let musicItemDetailRepository = MusicItemDetailTestRepository { selectedItem in
            #expect(selectedItem == item)
            return detailData
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        #expect(model.state == .loading)
        await model.load()
        #expect(model.state == .content(detail))
    }

    @Test func unavailableItem() async {
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in
            throw MusicItemDetailError.unavailable
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        await model.load()
        #expect(model.state == .unavailable)
    }

    @Test func retryAfterFailure() async {
        var attempts = 0
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in
            attempts += 1

            if attempts == 1 {
                throw URLError(.notConnectedToInternet)
            }

            return detailData
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        await model.load()
        #expect(model.state == .error)
        await model.load()
        #expect(model.state == .content(detail))
        #expect(attempts == 2)
    }

    @Test func cancellationDoesNotShowError() async {
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in
            throw CancellationError()
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        await model.load()
        #expect(model.state == .loading)
    }

    @Test func cancelledTaskDoesNotCommitResult() async {
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in detailData }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        let task = Task { await model.load() }
        task.cancel()
        await task.value
        #expect(model.state == .loading)
    }

    @Test func olderRequestCannotOverwriteRetry() async {
        var pending: CheckedContinuation<MusicItemDetailData, Never>?
        var started: CheckedContinuation<Void, Never>?
        var attempts = 0
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in
            attempts += 1

            if attempts == 1 {
                return await withCheckedContinuation { continuation in
                    pending = continuation
                    started?.resume()
                }
            }

            return detailData
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        let first = Task { await model.load() }
        await withCheckedContinuation { started = $0 }
        await model.load()
        let staleAlbum = MusicAlbumMetadata(sourceID: "stale",
                                           source: .library,
                                           title: "Stale",
                                           artistName: "Artist",
                                           trackCount: 0,
                                           imageURL: nil)
        pending?.resume(returning: .album(staleAlbum, songs: []))
        await first.value
        #expect(model.state == .content(detail))
    }

    @Test func appendsUniqueArtistItemsFromNextPage() async {
        let cursor = MusicItemDetailPageCursor()
        let firstItem = MusicItemMetadata.album(MusicAlbumMetadata(sourceID: "1",
                                                                   source: .catalog,
                                                                   title: "First",
                                                                   artistName: "Artist",
                                                                   trackCount: 10,
                                                                   imageURL: nil))
        let secondItem = MusicItemMetadata.album(MusicAlbumMetadata(sourceID: "2",
                                                                    source: .catalog,
                                                                    title: "Second",
                                                                    artistName: "Artist",
                                                                    trackCount: 12,
                                                                    imageURL: nil))
        var relationships = MusicArtistRelationships()
        relationships.fullAlbums = MusicItemDetailPage(items: [firstItem], nextPageCursor: cursor)
        let detailData = MusicItemDetailData.artist(artistMetadata, relationships: relationships)
        let musicItemDetailRepository = MusicItemDetailTestRepository(detailHandler: { _ in detailData },
                                                                      pageHandler: { requestedCursor in
            #expect(requestedCursor == cursor)
            return MusicItemDetailPage(items: [firstItem, secondItem], nextPageCursor: nil)
        })
        let item = MusicItem(sourceID: "artist",
                             source: .catalog,
                             type: .artist,
                             title: "Artist",
                             subtitle: "Rock",
                             imageURL: nil)
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        await model.load()
        await model.loadNextPage(sectionID: .albums)

        guard case .content(let loadedDetail) = model.state,
              case .artist(let loadedArtistDetail) = loadedDetail.content,
              let loadedSection = loadedArtistDetail.sections.first else {
            Issue.record("Expected loaded artist detail")
            return
        }

        #expect(loadedSection.items == [firstItem, secondItem].map(MusicItemDetailPresentationMapper().makeItem))
        #expect(loadedSection.nextPageCursor == nil)
        #expect(model.loadingSectionIDs.isEmpty)
        #expect(model.failedSectionIDs.isEmpty)
    }

    @Test func marksOnlyFailedArtistSectionForRetry() async {
        let cursor = MusicItemDetailPageCursor()
        let song = MusicSongMetadata(sourceID: "song",
                                     source: .catalog,
                                     title: "Song",
                                     artistName: "Artist",
                                     albumTitle: nil,
                                     duration: nil,
                                     imageURL: nil)
        var relationships = MusicArtistRelationships()
        relationships.topSongs = MusicItemDetailPage(items: [.song(song)], nextPageCursor: cursor)
        let detailData = MusicItemDetailData.artist(artistMetadata, relationships: relationships)
        let detail = MusicItemDetailPresentationMapper().makeDetail(from: detailData)
        var attempts = 0
        let musicItemDetailRepository = MusicItemDetailTestRepository(detailHandler: { _ in detailData },
                                                                      pageHandler: { _ in
            attempts += 1

            if attempts == 1 {
                throw URLError(.networkConnectionLost)
            }

            return MusicItemDetailPage(items: [], nextPageCursor: nil)
        })
        let item = MusicItem(sourceID: "artist",
                             source: .catalog,
                             type: .artist,
                             title: "Artist",
                             subtitle: "",
                             imageURL: nil)
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        await model.load()
        await model.loadNextPage(sectionID: .topSongs)
        #expect(model.loadingSectionIDs.isEmpty)
        #expect(model.failedSectionIDs == [.topSongs])
        #expect(model.state == .content(detail))
        await model.loadNextPage(sectionID: .topSongs)
        #expect(attempts == 2)
        #expect(model.failedSectionIDs.isEmpty)

        guard case .content(let loadedDetail) = model.state,
              case .artist(let artistDetail) = loadedDetail.content else {
            Issue.record("Expected artist detail after retry")
            return
        }

        #expect(artistDetail.sections.first?.nextPageCursor == nil)
    }
}
