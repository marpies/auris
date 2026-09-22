//
//  MusicGenreChartsView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct MusicGenreChartsView: View {
    @State private var viewModel: MusicGenreChartsViewModel
    
    private var sections: [MusicSearchResultSectionKind]? {
        switch viewModel.state {
        case .content:
            let sections = viewModel.searchResultsSections
            if !sections.isEmpty {
                return sections
            }
            return nil
        default:
            return nil
        }
    }

    init(viewModel: MusicGenreChartsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading charts…")
            case .content(let section):
                VStack(spacing: 0) {
                    if let sections {
                        SearchSectionFilterView(section: $viewModel.resultsSection, sections: sections)
                        
                        Divider()
                    }
                    
                    ScrollView {
                        SearchResultsView(section: section, recordsRecentSelection: false)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                    }
                }
            case .empty:
                ContentUnavailableView("No Charts Available",
                                       systemImage: "chart.bar",
                                       description: Text("There are no charts for this genre right now."))
            case .error:
                RetryErrorView(title: "Charts Unavailable",
                               message: "Auris couldn’t load this genre’s charts. Please try again.") {
                    await viewModel.load(force: true)
                }
            }
        }
        .navigationTitle(viewModel.genre.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.load(force: false)
        }
    }
}
