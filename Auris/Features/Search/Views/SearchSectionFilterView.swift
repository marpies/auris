//
//  SearchSectionFilterView.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/22/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI

struct SearchSectionFilterView: View {
    @Binding private var section: MusicSearchResultSectionKind
    private let sections: [MusicSearchResultSectionKind]

    init(section: Binding<MusicSearchResultSectionKind>, sections: [MusicSearchResultSectionKind]) {
        _section = section
        self.sections = sections
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 8) {
                ForEach(sections) { section in
                    Button {
                        self.section = section
                    } label: {
                        Text(section.title)
                            .font(.caption.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(self.section == section
                                        ? Color(.tintColor)
                                        : Color(.clear), in: Capsule())
                            .foregroundStyle(self.section == section
                                             ? .white
                                             : .primary)
                            .transition(.opacity)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
            .padding(.top, 4)
            .padding(.bottom, 8)
        }
        .scrollIndicators(.hidden)
        .fixedSize(horizontal: false, vertical: true)
    }
}
