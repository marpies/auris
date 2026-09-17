//
//  MusicArtistPaginationStore.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

actor MusicArtistPaginationStore {
    private var batches: [MusicItemDetailPageCursor: MusicArtistPaginationBatch] = [:]

    func reset() {
        batches.removeAll()
    }

    func register(batch: MusicArtistPaginationBatch) -> MusicItemDetailPageCursor? {
        guard batch.hasNextBatch else { return nil }

        let cursor = MusicItemDetailPageCursor()
        batches[cursor] = batch
        return cursor
    }

    func takeBatch(cursor: MusicItemDetailPageCursor) -> MusicArtistPaginationBatch? {
        batches.removeValue(forKey: cursor)
    }

    func restore(batch: MusicArtistPaginationBatch, cursor: MusicItemDetailPageCursor) {
        batches[cursor] = batch
    }
}
