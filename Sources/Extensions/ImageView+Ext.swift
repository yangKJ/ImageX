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
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        HandyImage.displayImage(named: named, to: base, filters: filters, options: options, other: nil)
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
    ///
    /// - Note:
    /// This is the easiest way to use ImagX to boost the image setting process from a source.
    /// You can set an image from a certain URL to an image view like this:
    ///
    /// ```
    /// // Set image from a url.
    /// let url = URL(string: "https://example.com/image.png")!
    /// imageView.mt.setImage(with: url)
    ///
    /// // Or set other parameters play gif or downloading image.
    /// var options = AnimatedOptions(moduleName: "Component Name")
    /// options.loop = .count(3)
    /// options.placeholder = .image(R.image("AppIcon")!)
    /// options.contentMode = .scaleAspectBottomRight
    /// options.bufferCount = 20
    /// options.cacheOption = .disk
    /// options.cacheCrypto = .user { "Condy" + CryptoType.SHA.sha1(string: $0) }
    /// options.cacheDataZip = .gzip
    /// options.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
    ///
    /// let url = URL(string: "https://example.com/image.png")!
    /// imageView.mt.setImage(with: url, options: options)
    /// ```
    ///
    @discardableResult public func setImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: nil)
    }
}
