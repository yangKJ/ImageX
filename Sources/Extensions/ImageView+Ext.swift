//
//  ImageView+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/1/5.
//

import Foundation
import Harbeth
#if os(iOS) || os(tvOS)
import UIKit
public typealias ImageView = UIImageView
#elseif os(macOS)
import AppKit
public typealias ImageView = NSImageView
#endif

extension ImageView: AsAnimatable, ImageContainer, C7Compatible { }

extension Queen where Base: ImageView {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setImage(named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        HandyImage.displayImage(named: named, to: base, filters: filters, options: options, other: nil)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setImage(
        data: Data?,
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
    ///   - failed: Network failure callback.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setImage(
        url: URL,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default,
        failed: AnimatedOptions.FailedCallback? = nil
    ) -> URLSessionDataTask? {
        var options = options
        if let failed = failed  {
            options.setNetworkFailed { failed($0, $1) }
        }
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: nil)
    }
}
