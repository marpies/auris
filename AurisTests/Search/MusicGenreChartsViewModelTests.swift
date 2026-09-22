//
//  MusicGenreChartsViewModelTests.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation
import Testing
@testable import Auris

@MainActor
struct MusicGenreChartsViewModelTests {
    private let genre = MusicGenre(sourceID: "genre", name: "Rock")

    @Test func loadsChartSections() async {
        let item = MusicItem(sourceID: "song",
                             source: .catalog,
                             type: .song,
                             title: "Dreams",
                             subtitle: "Fleetwood Mac",
                             imageURL: nil)
        let section = MusicSearchResultSection(kind: .songs, items: [item])
        let results = MusicSearchResults(sections: [section])
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.loadChartsHandler = { requestedGenre in
            #expect(requestedGenre == self.genre)
            return results
        }
        let model = MusicGenreChartsViewModel(genre: genre,
                                              musicSearchRepository: musicSearchRepository)
        await model.load(force: false)
        #expect(model.state == .content(section))
    }

    @Test func representsEmptyAndFailedCharts() async {
        var shouldFail = false
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.loadChartsHandler = { _ in
            if shouldFail {
                throw URLError(.notConnectedToInternet)
            }

            return MusicSearchResults(sections: [])
        }
        let model = MusicGenreChartsViewModel(genre: genre,
                                              musicSearchRepository: musicSearchRepository)
        await model.load(force: false)
        #expect(model.state == .empty)
        shouldFail = true
        await model.load(force: true)
        #expect(model.state == .error)
    }
}
