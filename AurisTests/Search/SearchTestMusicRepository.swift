//
//  SearchTestMusicRepository.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

@testable import Auris

@MainActor
final class SearchTestMusicRepository: MusicSearchRepository {
    var loadGenresHandler: () async throws -> [MusicGenre] = { [] }
    var searchHandler: (String, MusicSearchTarget) async throws -> MusicSearchResults = { _, _ in
        MusicSearchResults(sections: [])
    }
    var loadChartsHandler: (MusicGenre) async throws -> MusicSearchResults = { _ in
        MusicSearchResults(sections: [])
    }

    func loadGenres() async throws -> [MusicGenre] {
        try await loadGenresHandler()
    }

    func search(term: String, target: MusicSearchTarget) async throws -> MusicSearchResults {
        try await searchHandler(term, target)
    }

    func loadCharts(genre: MusicGenre) async throws -> MusicSearchResults {
        try await loadChartsHandler(genre)
    }
}
