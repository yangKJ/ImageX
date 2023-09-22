//
//  WKInterfaceImage+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/7/3.
//

import Foundation
import Harbeth

#if canImport(WatchKit)
import WatchKit

extension WKInterfaceImage: AsAnimatable, WKInterfaceImageContainer, ImageXCompatible { }

extension ImageXEngine where Base: WKInterfaceImage {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents creating options used in ImageX.
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: ImageXOptions = .default) {
        Driver.setImage(named: named, to: base, filters: filters, options: options, other: nil)
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
        Driver.setImage(data: data, to: base, filters: filters, options: options, other: nil)
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
    ) -> Task? {
        Driver.setImage(url: url, to: base, filters: filters, options: options, other: nil)
    }
}

#endif
