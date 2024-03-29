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

extension NSButton: AsAnimatable, NSButtonContainer, ImageXCompatible { }

extension ImageXEngine where Base: NSButton {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: ImageXOptions = .default) {
        let other = Others(key: Others.NSButtonKey.image.rawValue, value: nil)
        Driver.setImage(named: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setImage(
        with data: Data?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: ImageXOptions = ImageXOptions.default
    ) -> AssetType {
        let other = Others(key: Others.NSButtonKey.image.rawValue, value: nil)
        return Driver.setImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: ImageXOptions = ImageXOptions.default
    ) -> ImageX.Task? {
        let other = Others(key: Others.NSButtonKey.image.rawValue, value: nil)
        return Driver.setImage(url: url, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    public func setAlternateImage(with named: String?, filters: [C7FilterProtocol] = [], options: ImageXOptions = .default) {
        let other = Others(key: Others.NSButtonKey.alternateImage.rawValue, value: nil)
        Driver.setImage(named: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setAlternateImage(
        with data: Data?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: ImageXOptions = ImageXOptions.default
    ) -> AssetType {
        let other = Others(key: Others.NSButtonKey.alternateImage.rawValue, value: nil)
        return Driver.setImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setAlternateImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: ImageXOptions = ImageXOptions.default
    ) -> ImageX.Task? {
        let other = Others(key: Others.NSButtonKey.alternateImage.rawValue, value: nil)
        return Driver.setImage(url: url, to: base, filters: filters, options: options, other: other)
    }
}

#endif
