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
    
    private let dependencies: HomeViewModelDependencies

    init(dependencies: HomeViewModelDependencies) {
        self.dependencies = dependencies
    }
    
    func load() async {
        state = .loading

        do {
            let content = try await homeContentRepository.load()
            
            try Task.checkCancellation()

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
        } catch {
            guard !Task.isCancelled else { return }

            state = .error
        }
    }

    func requestAuthorization() async {
        let status = await musicAuthorizationService.requestAuthorization()
        
        switch status {
        case .notDetermined:
            return
            
        case .authorized, .denied, .restricted:
            await load()
        }
    }
}

extension HomeViewModel {
    var homeContentRepository: any HomeContentRepository { dependencies.homeContentRepository }
    var musicAuthorizationService: any MusicAuthorizationService { dependencies.musicAuthorizationService }
}
