//
//  SearchViewModel.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import Foundation

@Observable
@MainActor
final class SearchViewModel {
    private(set) var accessState: SearchAccessState = .loading
    private(set) var genreState: SearchGenreState = .loading
    private(set) var resultsState: SearchResultsState = .idle
    private(set) var recentItems: [MusicItem] = []
    
    var searchResultsSections: [MusicSearchResultSectionKind] {
        guard let searchResults, !searchResults.isEmpty else { return [] }
        
        return searchResults.sections.map { $0.id }
    }
    
    var resultsSection: MusicSearchResultSectionKind = .topResults {
        didSet {
            guard let searchResults,
                  let section = searchResults.sections.first(where: { $0.id == resultsSection }) else { return }
            
            switch resultsState {
            case .content:
                resultsState = .content(section)
            default:
                return
            }
        }
    }

    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }

            scheduleSearch()
        }
    }
    var searchTarget: MusicSearchTarget = .catalog {
        didSet {
            guard searchTarget != oldValue else { return }

            searchImmediately()
        }
    }

    private static let minimumSearchLength = 2
    private static let searchDelay = Duration.milliseconds(500)
    
    private var searchResults: MusicSearchResults?
    private var didLoad = false
    private var searchTask: Task<Void, Never>?
    private var searchRequestID = UUID()

    private let dependencies: SearchViewModelDependencies

    init(dependencies: SearchViewModelDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        guard !didLoad else { return }

        didLoad = true
        recentItems = await recentSearchRepository.load()
        await applyAuthorizationStatus(musicAuthorizationService.currentStatus)

        guard !Task.isCancelled else {
            didLoad = false
            return
        }
    }

    func requestAuthorization() async {
        let status = await musicAuthorizationService.requestAuthorization()
        await applyAuthorizationStatus(status)
    }

    func retryGenres() async {
        await loadGenres()
    }

    func retrySearch() {
        searchImmediately()
    }

    func recordSearchResult(_ item: MusicItem) async {
        recentItems = await recentSearchRepository.record(item: item)
    }

    private func applyAuthorizationStatus(_ status: MusicAuthorizationStatus) async {
        switch status {
        case .notDetermined:
            cancelCurrentSearch()
            resultsState = .idle
            accessState = .unauth
        case .denied:
            cancelCurrentSearch()
            resultsState = .idle
            accessState = .denied
        case .restricted:
            cancelCurrentSearch()
            resultsState = .idle
            accessState = .restricted
        case .authorized:
            accessState = .content
            await loadGenres()

            guard !Task.isCancelled else { return }

            scheduleSearch()
        }
    }

    private func loadGenres() async {
        genreState = .loading

        do {
            let genres = try await musicSearchRepository.loadGenres()
            try Task.checkCancellation()
            genreState = .content(genres)
        } catch {
            guard !Task.isCancelled else { return }

            genreState = .error
        }
    }

    private func scheduleSearch() {
        let term = normalizedSearchTerm
        cancelCurrentSearch()

        guard accessState == .content else {
            resultsState = .idle
            return
        }

        guard term.count >= Self.minimumSearchLength else {
            resultsState = .idle
            return
        }

        let requestID = searchRequestID
        let target = searchTarget
        resultsState = .loading
        searchTask = Task {
            do {
                try await Task.sleep(for: Self.searchDelay)
                await performSearch(term: term, target: target, requestID: requestID)
            } catch {
                return
            }
        }
    }

    private func searchImmediately() {
        let term = normalizedSearchTerm
        cancelCurrentSearch()

        guard accessState == .content else {
            resultsState = .idle
            return
        }

        guard term.count >= Self.minimumSearchLength else {
            resultsState = .idle
            return
        }

        let requestID = searchRequestID
        let target = searchTarget
        resultsState = .loading
        searchTask = Task {
            await performSearch(term: term, target: target, requestID: requestID)
        }
    }

    private func performSearch(term: String,
                               target: MusicSearchTarget,
                               requestID: UUID) async {
        do {
            let results = try await musicSearchRepository.search(term: term, target: target)
            try Task.checkCancellation()

            guard requestID == searchRequestID else { return }

            if !results.isEmpty, let section = results.sections.first {
                searchResults = results
                resultsState = .content(section)
                resultsSection = section.id
            } else {
                searchResults = nil
                resultsState = .empty
            }
        } catch {
            guard !Task.isCancelled, requestID == searchRequestID else { return }

            resultsState = .error
        }
    }

    private func cancelCurrentSearch() {
        searchTask?.cancel()
        searchTask = nil
        searchRequestID = UUID()
    }

    private var normalizedSearchTerm: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension SearchViewModel {
    var musicSearchRepository: any MusicSearchRepository { dependencies.musicSearchRepository }
    var recentSearchRepository: any RecentSearchRepository { dependencies.recentSearchRepository }
    var musicAuthorizationService: any MusicAuthorizationService { dependencies.musicAuthorizationService }
}
