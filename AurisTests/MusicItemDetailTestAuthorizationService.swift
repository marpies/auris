//
//  MusicItemDetailTestAuthorizationService.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/15/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

@testable import Auris

struct MusicItemDetailTestAuthorizationService: MusicAuthorizationService {
    let currentStatus: MusicAuthorizationStatus

    func requestAuthorization() async -> MusicAuthorizationStatus {
        currentStatus
    }
}
