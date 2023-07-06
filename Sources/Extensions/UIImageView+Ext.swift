//
//  UIImageView+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/7/3.
//

import Foundation
import Harbeth

#if canImport(UIKit) && !os(watchOS)
import UIKit

public typealias ImageView = UIImageView

extension UIImageView: AsAnimatable, UIImageViewContainer, C7Compatible { }

extension Queen where Base: UIImageView {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.image.rawValue, value: nil)
        HandyImage.displayImage(source: named, to: base, filters: filters, options: options, other: other)
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
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.image.rawValue, value: nil)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
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
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.image.rawValue, value: nil)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    public func setHighlightedImage(with named: String?, filters: [C7FilterProtocol] = [], options: AnimatedOptions = .default) {
        self.base.animationRepeatCount = options.loop.count
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.highlightedImage.rawValue, value: nil)
        HandyImage.displayImage(source: named, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func setHighlightedImage(
        with data: Data?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        self.base.animationRepeatCount = options.loop.count
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.highlightedImage.rawValue, value: nil)
        return HandyImage.displayImage(data: data, to: base, filters: filters, options: options, other: other)
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func setHighlightedImage(
        with url: URL?,
        filters: [Harbeth.C7FilterProtocol] = [],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> URLSessionDataTask? {
        self.base.animationRepeatCount = options.loop.count
        let other = AnimatedOthers(key: AnimatedOthers.UIImageViewKey.highlightedImage.rawValue, value: nil)
        return HandyImage.displayImage(url: url, to: base, filters: filters, options: options, other: other)
    }
}

#endif
