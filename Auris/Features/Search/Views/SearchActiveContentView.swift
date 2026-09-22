//
//  SearchActiveContentView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

import SwiftUI

struct SearchActiveContentView: View {
    @State private var searchFocusObserver = SearchFocusObserver()
    
    let viewModel: SearchViewModel
    @Binding var searchTarget: MusicSearchTarget
    @Binding var section: MusicSearchResultSectionKind
    
    private var sections: [MusicSearchResultSectionKind]? {
        switch viewModel.resultsState {
        case .content:
            let sections = viewModel.searchResultsSections
            if !searchFocusObserver.isFocused && !sections.isEmpty {
                return sections
            }
            return nil
        default:
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let sections {
                SearchSectionFilterView(section: $section, sections: sections)
            } else {
                searchTargetPicker
            }

            Divider()

            switch viewModel.resultsState {
            case .idle:
                SearchRecentItemsView(items: viewModel.recentItems)
            case .loading:
                ProgressView("Searching…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .content(let section):
                ScrollView {
                    SearchResultsView(section: section, recordsRecentSelection: true)
                        .padding(.horizontal)
                        .padding(.vertical, 12)
                }
            case .empty:
                ContentUnavailableView.search
            case .error:
                RetryErrorView(title: "Search Unavailable",
                               message: "Auris couldn’t complete your search. Please try again.") {
                    viewModel.retrySearch()
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: searchFocusObserver.isFocused)
        .animation(.easeInOut(duration: 0.25), value: section)
    }
    
    private func filtersView(_ sections: [MusicSearchResultSectionKind]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(sections) { section in
                    Button {
                        self.section = section
                    } label: {
                        Text(section.title)
                            .font(.caption.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(self.section == section
                                        ? Color(.tintColor)
                                        : Color(.clear), in: Capsule())
                            .foregroundStyle(self.section == section
                                             ? .white
                                             : .primary)
                            .transition(.opacity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
        }
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true)
    }
    
    private var searchTargetPicker: some View {
        return Picker("Search in", selection: $searchTarget) {
            Text(MusicSearchTarget.catalog.title)
                .tag(MusicSearchTarget.catalog)
            Text(MusicSearchTarget.library.title)
                .tag(MusicSearchTarget.library)
        }
        .pickerStyle(.segmented)
        .padding()
        .transition(.opacity)
    }
}
