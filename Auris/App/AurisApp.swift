//
//  AurisApp.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

@main
struct AurisApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var delegate
    
    private let compositionRoot: AppCompositionRoot = AppCompositionRoot.shared
    
    var body: some Scene {
        let homeFactory = compositionRoot.resolve((any HomeFactory).self)
        let libraryFactory = compositionRoot.resolve((any LibraryFactory).self)
        let searchFactory = compositionRoot.resolve((any SearchFactory).self)
        let homeCoordinator = HomeCoordinator(factory: homeFactory)
        let libraryCoordinator = LibraryCoordinator(factory: libraryFactory)
        let searchCoordinator = SearchCoordinator(searchFactory: searchFactory)

        WindowGroup {
            ContentView(homeCoordinator: homeCoordinator,
                        libraryCoordinator: libraryCoordinator,
                        searchCoordinator: searchCoordinator)
        }
    }
}
