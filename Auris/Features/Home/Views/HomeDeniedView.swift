//
//  HomeDeniedView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/14/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct HomeDeniedView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "nosign")
                .font(.system(size: 60))
                .frame(width: 60, height: 60)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("Access denied.")
                    .font(.largeTitle.bold())
                
                Text("Access to Apple Music has been denied. Modify the permission in the Settings app.")
                    .font(.body)
                    .multilineTextAlignment(.center)
            }
            
            Button("Open Settings…") {
                
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    HomeDeniedView()
}
