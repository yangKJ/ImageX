//
//  Placeholder.swift
//  ImageX
//
//  Created by Condy on 2023/2/28.
//

import Foundation
import Harbeth
#if os(iOS) || os(tvOS)
import UIKit
public typealias ImageXView = UIView
#elseif os(macOS)
import AppKit
public typealias ImageXView = NSView
#endif

/// Represent a placeholder type which could be set while loading as well as loading finished without getting an image.
public enum Placeholder {
    /// Do not use any placeholder.
    case none
    /// Use solid color image as placeholder.
    case color(C7Color)
    /// Use image as placeholder.
    case image(C7Image)
    /// Use a custom view as placeholder.
    case view(ImageXView)
}

extension ImageX.Placeholder {
    
    /// Displayed placeholder on view.
    func display(to view: AsAnimatable, contentMode: ImageX.ContentMode, other: ImageX.Others? = nil) {
        DispatchQueue.main.async {
            switch self {
            case .none:
                break
            case .color(let c7Color):
                var image = c7Color.mt.colorImage(with: view.frame.size)
                image = contentMode.resizeImage(image, size: view.frame.size)
                view.setContentImage(image, other: other)
            case .image(let c7Image):
                let image = contentMode.resizeImage(c7Image, size: view.frame.size)
                view.setContentImage(image, other: other)
            case .view(let subview):
                if let view = view as? ImageXView, !view.subviews.contains(subview) {
                    view.addSubview(subview)
                    subview.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        subview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        subview.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                        subview.heightAnchor.constraint(equalTo: view.heightAnchor),
                        subview.widthAnchor.constraint(equalTo: view.widthAnchor),
                    ])
                }
            }
        }
    }
    
    /// Remove placeholder from view.
    func remove(from view: AsAnimatable, other: ImageX.Others? = nil) {
        DispatchQueue.main.async {
            switch self {
            case .none:
                break
            case .color, .image:
                view.setContentImage(nil, other: other)
            case .view(let subview):
                if let view = view as? ImageXView, view.subviews.contains(subview) {
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
