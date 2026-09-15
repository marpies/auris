//
//  HomeRestrictedView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct HomeRestrictedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Apple Music is restricted")
                    .font(.largeTitle.bold())

                Text("Apple Music access is restricted on this device and can’t be changed from Auris.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    HomeRestrictedView()
}
