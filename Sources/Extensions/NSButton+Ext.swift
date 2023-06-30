//
//  NSButton+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/6/30.
//

import Foundation
import Harbeth

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

import AppKit

extension NSButton: AsAnimatable, NSButtonContainer, C7Compatible { }

extension Queen where Base: NSButton {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.image.rawValue, value: nil)
        HandyImage.displayImage(named: named, to: base, filters: filters, options: options, other: other)
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
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.image.rawValue, value: nil)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
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
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.image.rawValue, value: nil)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setAlternateImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.alternateImage.rawValue, value: nil)
        HandyImage.displayImage(named: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setAlternateImage(
        with data: Data?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.alternateImage.rawValue, value: nil)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setAlternateImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        let other = AnimatedOthers(key: AnimatedOthers.NSButtonKey.alternateImage.rawValue, value: nil)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
}

#endif
