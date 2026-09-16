//
//  DefaultHomeContentRepository.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import MusicKit

struct DefaultHomeContentRepository: HomeContentRepository {
    private let musicAuthorizationService: any MusicAuthorizationService

    init(musicAuthorizationService: any MusicAuthorizationService) {
        self.musicAuthorizationService = musicAuthorizationService
    }
    
    func load() async throws -> HomeContent {
        let status = musicAuthorizationService.currentStatus
        
        switch status {
        case .notDetermined:
            return .unauth
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .library([])
        @unknown default:
            return .restricted
        }
    }
}
