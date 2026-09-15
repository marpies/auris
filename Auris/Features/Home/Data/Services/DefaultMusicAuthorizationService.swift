//
//  DefaultMusicAuthorizationService.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import Foundation
import MusicKit

struct DefaultMusicAuthorizationService: MusicAuthorizationService {
    var currentStatus: MusicAuthorizationStatus {
        map(MusicAuthorization.currentStatus)
    }
    
    func requestAuthorization() async -> MusicAuthorizationStatus {
        let status = await MusicAuthorization.request()
        return map(status)
    }
    
    private func map(_ status: MusicAuthorization.Status) -> MusicAuthorizationStatus {
        switch status {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized:
            return .authorized
        @unknown default:
            return .restricted
        }
    }
}
