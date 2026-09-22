//
//  MusicGenreChartsViewModel.swift
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
final class MusicGenreChartsViewModel {
    let genre: MusicGenre

    private(set) var state: MusicGenreChartsState = .loading
    
    var searchResultsSections: [MusicSearchResultSectionKind] {
        guard let searchResults, !searchResults.isEmpty else { return [] }
        
        return searchResults.sections.map { $0.id }
    }
    
    var resultsSection: MusicSearchResultSectionKind = .topResults {
        didSet {
            guard let searchResults,
                  let section = searchResults.sections.first(where: { $0.id == resultsSection }) else { return }
            
            switch state {
            case .content:
                state = .content(section)
            default:
                return
            }
        }
    }

    private var loadTask: Task<Void, Never>?
    private var searchResults: MusicSearchResults?
    private let musicSearchRepository: any MusicSearchRepository

    init(genre: MusicGenre, musicSearchRepository: any MusicSearchRepository) {
        self.genre = genre
        self.musicSearchRepository = musicSearchRepository
    }

    func load(force: Bool) async {
        if force {
            loadTask?.cancel()
            loadTask = nil
            state = .loading
        }

        if let loadTask {
            await loadTask.value
            return
        }

        loadTask = Task {
            await loadNow()
        }
        await loadTask?.value
    }

    private func loadNow() async {
        do {
            let results = try await musicSearchRepository.loadCharts(genre: genre)
            
            try Task.checkCancellation()
            
            if !results.isEmpty, let section = results.sections.first {
                searchResults = results
                state = .content(section)
                resultsSection = section.id
            } else {
                searchResults = nil
                state = .empty
            }
        } catch {
            guard !Task.isCancelled else { return }

            state = .error
        }
    }
}
