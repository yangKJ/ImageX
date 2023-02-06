//
//  ImageView+Ext.swift
//  Wintersweet
//
//  Created by Condy on 2023/2/6.
//

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
public typealias ImageView = UIImageView
#elseif os(macOS)
import AppKit
public typealias ImageView = NSImageView
#endif

extension ImageView: AsAnimatable, ImageContainer {
    
}
