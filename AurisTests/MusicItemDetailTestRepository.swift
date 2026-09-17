//
//  MusicItemDetailTestRepository.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

@testable import Auris

struct MusicItemDetailTestRepository: MusicItemDetailRepository {
    typealias DetailHandler = (MusicItem) async throws -> MusicItemDetailData
    typealias PageHandler = (MusicItemDetailPageCursor) async throws -> MusicItemDetailPage

    private let detailHandler: DetailHandler
    private let pageHandler: PageHandler

    init(detailHandler: @escaping DetailHandler,
         pageHandler: @escaping PageHandler = { _ in throw MusicItemDetailError.unavailable }) {
        self.detailHandler = detailHandler
        self.pageHandler = pageHandler
    }

    func load(item: MusicItem) async throws -> MusicItemDetailData {
        try await detailHandler(item)
    }

    func loadNextPage(cursor: MusicItemDetailPageCursor) async throws -> MusicItemDetailPage {
        try await pageHandler(cursor)
    }
}
