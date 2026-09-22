//
//  SearchTestAuthorizationService.swift
//  AurisTests
//
//  Created by Marcel Piešťanský on 09/17/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//

@testable import Auris

@MainActor
final class SearchTestAuthorizationService: MusicAuthorizationService {
    var currentStatus: MusicAuthorizationStatus
    var requestedStatus: MusicAuthorizationStatus

    init(currentStatus: MusicAuthorizationStatus = .authorized,
         requestedStatus: MusicAuthorizationStatus = .authorized) {
        self.currentStatus = currentStatus
        self.requestedStatus = requestedStatus
    }

    func requestAuthorization() async -> MusicAuthorizationStatus {
        currentStatus = requestedStatus
        return requestedStatus
    }
}
