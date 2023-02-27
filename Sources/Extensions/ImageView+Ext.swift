//
//  ImageView+Ext.swift
//  Wintersweet
//
//  Created by Condy on 2023/2/6.
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

extension ImageView: AsAnimatable, ImageContainer, C7Compatible {
    
}

extension Queen where Base: ImageView {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in Wintersweet.
    public func displayImage(named: String, filters: [C7FilterProtocol], options: AnimatedOptions = .default) {
        if let data = AnimatedOptions.gifData(named) {
            displayImage(data: data, filters: filters, options: options)
        } else if let image = AnimatedOptions.image(named) {
            self.base.hasAnimator?.prepareForReuse()
            let resizeImage = options.contentMode.resizeImage(image, size: base.frame.size)
            let dest = BoxxIO(element: resizeImage, filters: filters)
            self.base.image = try? dest.output()
        } else {
            self.base.image = options.contentMode.resizeImage(options.placeholder, size: base.frame.size)
        }
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in Wintersweet.
    /// - Returns: A uniform type identifier UTI.
    @discardableResult public func displayImage(
        data: Data?,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions = AnimatedOptions.default
    ) -> AssetType {
        let type = AssetType(data: data)
        switch type {
        case .jpeg, .png, .tiff, .webp, .heic, .heif:
            self.base.hasAnimator?.prepareForReuse()
            var image = Harbeth.C7Image.init(data: data!)
            image = options.contentMode.resizeImage(image, size: base.frame.size)
            let dest = BoxxIO(element: image, filters: filters)
            self.base.image = try? dest.output()
        case .gif:
            self.base.play(data: data, filters: filters, options: options)
        default:
            self.base.image = options.contentMode.resizeImage(options.placeholder, size: base.frame.size)
            self.base.hasAnimator?.prepareForReuse()
            break
        }
        return type
    }
    
    /// Display network image or gif and add the filters.
    /// - Parameters:
    ///   - url: Link url.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in Wintersweet.
    ///   - failed: Network failure callback.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func displayImage(
        url: URL,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions = AnimatedOptions.default,
        failed: FailedCallback? = nil
    ) -> URLSessionDataTask? {
        self.base.image = options.contentMode.resizeImage(options.placeholder, size: base.frame.size)
        let key = Cached.cacheKey(url: url)
        if let data: Data = options.cacheOption.read(key: key) {
            self.displayImage(data: data, filters: filters, options: options)
            return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            switch (data, error) {
            case (.none, let error):
                failed?(error)
            case (let data?, _):
                DispatchQueue.main.async {
                    self.displayImage(data: data, filters: filters, options: options)
                }
                options.cacheOption.write(key: key, value: data as NSData)
            }
        }
        task.resume()
        return task
    }
}
