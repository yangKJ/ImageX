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
    fileprivate func setImage(image: C7Image?, filters: [C7FilterProtocol], options: AnimatedOptions) {
        if options.displayed == false {
            options.placeholder.display(to: self, contentMode: options.contentMode)
        }
        self.hasAnimator?.prepareForReuse()
        let resizeImage = options.contentMode.resizeImage(image, size: self.frame.size)
        let dest = BoxxIO(element: resizeImage, filters: filters)
        if let outImage = try? dest.output() {
            options.placeholder.remove(from: self)
            self.setContentImage(outImage)
        }
    }
}

extension Queen where Base: ImageView {
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - named: Picture or gif name.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in Wintersweet.
    public func displayImage(named: String, filters: [C7FilterProtocol], options: AnimatedOptions = .default) {
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: base, contentMode: options.contentMode)
        if let data = R.gifData(named) {
            displayImage(data: data, filters: filters, options: options)
        } else if let image = R.image(named) {
            base.setImage(image: image, filters: filters, options: options)
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
            let image = Harbeth.C7Image.init(data: data!)
            self.base.setImage(image: image, filters: filters, options: options)
        case .gif:
            self.base.play(data: data, filters: filters, options: options)
        default:
            if options.displayed == false {
                options.placeholder.display(to: base, contentMode: options.contentMode)
            }
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
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: base, contentMode: options.contentMode)
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
