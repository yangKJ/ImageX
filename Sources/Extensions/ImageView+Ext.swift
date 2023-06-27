//
//  ImageView+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/1/5.
//

import Foundation
import Harbeth
import Lemons
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
        let size = options.confirmSize == .zero ? self.frame.size : options.confirmSize
        let resizeImage = options.contentMode.resizeImage(image, size: size)
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
    ///   - options: Represents gif playback creating options used in ImageX.
    public func displayImage(named: String?, filters: [C7FilterProtocol], options: AnimatedOptions = .default) {
        guard let named = named, named.isEmpty == false else {
            options.placeholder.display(to: base, contentMode: options.contentMode)
            return
        }
        if R.verifyLink(named), let url = URL(string: named) {
            displayImage(url: url, filters: filters, options: options)
        } else {
            let options = options.setDisplayed(placeholder: true)
            options.placeholder.display(to: base, contentMode: options.contentMode)
            if let data = R.gifData(named, forResource: options.moduleName) {
                displayImage(data: data, filters: filters, options: options)
            } else if let image = R.image(named, forResource: options.moduleName) {
                base.setImage(image: image, filters: filters, options: options)
            }
        }
    }
    
    /// Display image or gif and add the filters.
    /// - Parameters:
    ///   - data: Picture data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
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
    ///   - options: Represents gif playback creating options used in ImageX.
    ///   - failed: Network failure callback.
    /// - Returns: Current network URLSessionDataTask.
    @discardableResult public func displayImage(
        url: URL,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions = AnimatedOptions.default,
        failed: AnimatedOptions.FailedCallback? = nil
    ) -> URLSessionDataTask? {
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: base, contentMode: options.contentMode)
        let key = options.cacheCrypto.encryptedString(with: url.absoluteString)
        let storager = Cached.shared.storage
        if let object = storager.fetchCached(forKey: key, options: options.cacheOption), var data = object.data {
            data = options.cacheDataZip.decompress(data: data)
            self.displayImage(data: data, filters: filters, options: options)
            return nil
        }
        return Networking.shared.addDownloadURL(url, retry: options.retry) { (data, response, error) in
            switch (data, error) {
            case (.none, let error):
                failed?(response, error)
                options.failed?(response, error)
            case (let data?, _):
                DispatchQueue.main.async {
                    self.displayImage(data: data, filters: filters, options: options)
                }
                let zipData = options.cacheDataZip.compressed(data: data)
                let model = CacheModel(data: zipData)
                storager.storeCached(model, forKey: key, options: options.cacheOption)
            }
        }
    }
}
