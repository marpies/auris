//
//  HomeViewModel.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var state: HomeState = .loading
    
    private let homeContentRepository: any HomeContentRepository
    
    init(homeContentRepository: any HomeContentRepository) {
        self.homeContentRepository = homeContentRepository
    }
    
    func load() async throws {
        let content = try await homeContentRepository.load()
        
        switch content {
        case .denied:
            state = .denied
        case .library:
            state = .content
        case .restricted:
            state = .restricted
        case .unauth:
            state = .unauth
        }
    }
}
