//
//  UI+macOS.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/26.
//

import Foundation

#if os(macOS)
import AppKit

extension NSView {
    var backgroundColor: NSColor {
        get { return .white }
        set {
            self.layer?.backgroundColor = newValue.cgColor
            self.layoutSubtreeIfNeeded()
        }
    }
}

extension NSTextField {
    var text: String {
        get { return stringValue }
        set { stringValue = newValue }
    }
}

#endif
