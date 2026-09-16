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

    @Test func loadsEmptyCollection() async {
        let musicItemDetailRepository = MusicItemDetailTestRepository { selectedItem in
            #expect(selectedItem == item)
            return detail
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

            return detail
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
        let musicItemDetailRepository = MusicItemDetailTestRepository { _ in detail }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        let task = Task { await model.load() }
        task.cancel()
        await task.value
        #expect(model.state == .loading)
    }

    @Test func olderRequestCannotOverwriteRetry() async {
        var pending: CheckedContinuation<MusicItemDetail, Never>?
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

            return detail
        }
        let model = MusicItemDetailViewModel(item: item,
                                             musicItemDetailRepository: musicItemDetailRepository)
        let first = Task { await model.load() }
        await withCheckedContinuation { started = $0 }
        await model.load()
        pending?.resume(returning: MusicItemDetail(title: "Stale", subtitle: nil, imageURL: nil, content: .songs([])))
        await first.value
        #expect(model.state == .content(detail))
    }
}
