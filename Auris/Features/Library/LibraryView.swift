//
//  LibraryView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SwiftUI

struct LibraryView: View {
    private let viewModel: LibraryViewModel

    init(viewModel: LibraryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView()
            case let .content(content):
                LibraryMusicContentView(items: content.items)
            case .error:
                RetryErrorView(title: "Something went wrong.", message: "Auris couldn’t load your music library. Please try again.") {
                    await viewModel.load(force: true)
                }
            }
        }
        .task {
            await viewModel.load(force: false)
        }
    }
}
