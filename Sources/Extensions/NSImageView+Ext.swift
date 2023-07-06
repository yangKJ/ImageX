//
//  NSImageView+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/1/5.
//

import Foundation
import Harbeth

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public typealias ImageView = NSImageView

extension NSImageView: AsAnimatable, ImageContainer, C7Compatible { }

extension Queen where Base: NSImageView {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        HandyImage.displayImage(source: named, to: base, filters: filters, options: options, other: nil)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setImage(
        with data: Data?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: nil)
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: nil)
    }
}

#endif
