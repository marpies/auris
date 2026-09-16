//
//  LibraryViewModel.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/16/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import SwiftUI

@Observable
@MainActor
final class LibraryViewModel {
    private(set) var state: LibraryState = .loading
    
    private var loadTask: Task<Void, Never>?
    
    private let libraryContentRepository: any LibraryContentRepository

    init(libraryContentRepository: any LibraryContentRepository) {
        self.libraryContentRepository = libraryContentRepository
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
            let content = try await libraryContentRepository.load()
            state = .content(content)
        } catch {
            state = .error
        }
    }
}
