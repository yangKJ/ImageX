//
//  Typealias.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/25.
//

import Foundation
import SwiftUI

#if os(macOS)
import AppKit
public typealias CPImage = NSImage
public typealias CPView = NSView
public typealias CPColor = NSColor
public typealias CPImageView = NSImageView
public typealias CPButton = NSButton
public typealias CPLabel = NSTextField
public typealias CPViewRepresentable = NSViewRepresentable
public typealias CPViewRepresentableContext = NSViewRepresentableContext
#else
import UIKit
public typealias CPImage = UIImage
public typealias CPColor = UIColor
public typealias CPViewRepresentable = UIViewRepresentable
public typealias CPViewRepresentableContext = UIViewRepresentableContext
#if !os(watchOS)
public typealias CPImageView = UIImageView
public typealias CPView = UIView
public typealias CPButton = UIButton
public typealias CPLabel = UILabel
#if canImport(TVUIKit)
import TVUIKit
#endif
#if canImport(CarPlay) && !targetEnvironment(macCatalyst)
import CarPlay
#endif
#else
import WatchKit
#endif
#endif
