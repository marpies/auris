//
//  SearchViewModelTests.swift
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
struct SearchViewModelTests {
    @Test func loadsGenresAndRecentItemsWhenAuthorized() async {
        let genre = MusicGenre(sourceID: "genre", name: "Rock")
        let recentItem = makeItem(sourceID: "recent", source: .catalog)
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.loadGenresHandler = { [genre] }
        let recentSearchRepository = SearchTestRecentRepository(items: [recentItem])
        let model = makeViewModel(musicSearchRepository: musicSearchRepository,
                                  recentSearchRepository: recentSearchRepository)
        await model.load()
        #expect(model.accessState == .content)
        #expect(model.genreState == .content([genre]))
        #expect(model.recentItems == [recentItem])
    }

    @Test func requestsAuthorizationAndLoadsGenres() async {
        let musicSearchRepository = SearchTestMusicRepository()
        let musicAuthorizationService = SearchTestAuthorizationService(currentStatus: .notDetermined,
                                                                        requestedStatus: .authorized)
        let model = makeViewModel(musicSearchRepository: musicSearchRepository,
                                  musicAuthorizationService: musicAuthorizationService)
        await model.load()
        #expect(model.accessState == .unauth)
        await model.requestAuthorization()
        #expect(model.accessState == .content)
        #expect(model.genreState == .content([]))
    }

    @Test func ignoresSearchTermsShorterThanTwoCharacters() async throws {
        var searchCount = 0
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.searchHandler = { _, _ in
            searchCount += 1
            return MusicSearchResults(sections: [])
        }
        let model = makeViewModel(musicSearchRepository: musicSearchRepository)
        await model.load()
        model.searchText = "a"
        try await Task.sleep(for: .milliseconds(600))
        #expect(searchCount == 0)
        #expect(model.resultsState == .idle)
    }

    @Test func debouncesSearchAndUsesSelectedTarget() async throws {
        var receivedTerm: String?
        var receivedTarget: MusicSearchTarget?
        let item = makeItem(sourceID: "result", source: .library)
        let section = MusicSearchResultSection(kind: .songs, items: [item])
        let results = MusicSearchResults(sections: [section])
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.searchHandler = { term, target in
            receivedTerm = term
            receivedTarget = target
            return results
        }
        let model = makeViewModel(musicSearchRepository: musicSearchRepository)
        await model.load()
        model.searchTarget = .library
        model.searchText = "  dreams  "
        try await waitUntil {
            receivedTerm != nil && receivedTarget != nil && model.resultsState == .content(section)
        }
        #expect(receivedTerm == "dreams")
        #expect(receivedTarget == .library)
        #expect(model.resultsState == .content(section))
    }

    @Test func changingTargetRepeatsCurrentSearchImmediately() async throws {
        var targets: [MusicSearchTarget] = []
        let musicSearchRepository = SearchTestMusicRepository()
        musicSearchRepository.searchHandler = { _, target in
            targets.append(target)
            return MusicSearchResults(sections: [])
        }
        let model = makeViewModel(musicSearchRepository: musicSearchRepository)
        await model.load()
        model.searchText = "dreams"
        try await waitUntil {
            targets.count == 1 && model.resultsState == .empty
        }
        model.searchTarget = .library
        try await waitUntil {
            targets.count == 2 && model.resultsState == .empty
        }
        #expect(targets == [.catalog, .library])
        #expect(model.resultsState == .empty)
    }

    @Test func recordsOnlyExplicitlySelectedResult() async {
        let item = makeItem(sourceID: "selected", source: .catalog)
        let recentSearchRepository = SearchTestRecentRepository()
        let model = makeViewModel(recentSearchRepository: recentSearchRepository)
        await model.recordSearchResult(item)
        #expect(model.recentItems == [item])
    }

    private func waitUntil(_ condition: () -> Bool) async throws {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: .seconds(2))
        try Task.checkCancellation()

        while !condition() {
            try #require(clock.now < deadline, "Timed out waiting for the expected search state")
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    private func makeViewModel(musicSearchRepository: SearchTestMusicRepository? = nil,
                               recentSearchRepository: SearchTestRecentRepository? = nil,
                               musicAuthorizationService: SearchTestAuthorizationService? = nil) -> SearchViewModel {
        let dependencies = SearchViewModelDependencies(musicSearchRepository: musicSearchRepository ?? SearchTestMusicRepository(),
                                                       recentSearchRepository: recentSearchRepository ?? SearchTestRecentRepository(),
                                                       musicAuthorizationService: musicAuthorizationService ?? SearchTestAuthorizationService())
        return SearchViewModel(dependencies: dependencies)
    }

    private func makeItem(sourceID: String, source: MusicItemSource) -> MusicItem {
        MusicItem(sourceID: sourceID,
                  source: source,
                  type: .song,
                  title: "Dreams",
                  subtitle: "Fleetwood Mac",
                  imageURL: nil)
    }
}
