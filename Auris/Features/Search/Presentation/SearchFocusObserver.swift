//
//  SearchFocusObserver.swift
//  Auris
//
//  Created by Marcel Piešťanský on 09/21/2026.
//  Copyright © 2026 Marcel Piešťanský. All rights reserved.
//  
//  This program is free software. You can redistribute and/or modify it in
//  accordance with the terms of the accompanying license agreement.
//  

import SwiftUI
import UIKit
import Combine

@Observable
final class SearchFocusObserver {
    var isFocused = false
    
    private var tokens: [NSObjectProtocol] = []

    init() {
        let center = NotificationCenter.default
        tokens.append(center.addObserver(forName: UITextField.textDidBeginEditingNotification, object: nil, queue: .main) { [weak self] note in
            guard (note.object as? UITextField)?.isInsideSearchBar == true else { return }
            
            self?.isFocused = true
        })
        tokens.append(center.addObserver(forName: UITextField.textDidEndEditingNotification, object: nil, queue: .main) { [weak self] note in
            guard (note.object as? UITextField)?.isInsideSearchBar == true else { return }
            
            self?.isFocused = false
        })
    }

    deinit {
        tokens.forEach(NotificationCenter.default.removeObserver)
    }
}

private extension UITextField {
    var isInsideSearchBar: Bool {
        var view: UIView? = self
        
        while let v = view {
            if v is UISearchBar { return true }
            view = v.superview
        }
        
        return false
    }
}
