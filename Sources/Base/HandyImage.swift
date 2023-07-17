//
//  HandyImage.swift
//  ImageX
//
//  Created by Condy on 2023/6/29.
//

import Foundation
import Harbeth
import Lemons

struct HandyImage {
    
    static func displayImage(named: String?, to view: AsAnimatable, filters: [C7FilterProtocol], options: ImageXOptions, other: Others?) {
        guard let named = named, named.isEmpty == false else {
            view.hasAnimator?.prepareForReuse()
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            return
        }
        let options = HandyImage.setPlaceholder(to: view, options: options, other: other)
        if R.verifyLink(named), let url = URL(string: named) {
            HandyImage.displayImage(url: url, to: view, filters: filters, options: options, other: other)
        } else if let data = R.gifData(named, forResource: options.moduleName) {
            HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
        } else if let image = R.image(named, forResource: options.moduleName) {
            view.hasAnimator?.prepareForReuse()
            let options = HandyImage.setViewContentMode(to: view, options: options)
            let reimage = options.contentMode.resizeImage(image, size: options.thumbnailPixelSize)
            let dest = BoxxIO(element: reimage, filters: filters)
            if let outImage = try? dest.output() {
                view.setContentImage(outImage, other: other)
                switch options.placeholder {
                case .view:
                    options.placeholder.remove(from: view, other: other)
                default:
                    break
                }
            }
        }
    }
    
    @discardableResult static func displayImage(
        data: Data?,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: ImageXOptions,
        other: Others?
    ) -> AssetType {
        view.hasAnimator?.prepareForReuse()
        let options_ = HandyImage.setViewContentMode(to: view, options: options)
        let options = HandyImage.setPlaceholder(to: view, options: options_, other: other)
        guard let data = data else {
            return .unknow
        }
        let decoder = options.appointCoder ?? {
            AssetType(data: data).createDecoder(with: data)
        }()
        if let decoder = decoder as? AnimatedImageCoder, decoder.isAnimatedImages(), options.Animated.frameType == .animated {
            view.play(decoder: decoder, filters: filters, options: options, other: other)
        } else if let image = decoder?.decodedImage(options: options.setupDecoderOptions(filters)) {
            view.setContentImage(image, other: other)
        } else {
            HandyImage.setPlaceholder(to: view, options: options, other: other)
        }
        return decoder?.format ?? AssetType.unknow
    }
    
    @discardableResult static func displayImage(
        url: URL?,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: ImageXOptions,
        other: Others?
    ) -> Task? {
        guard let url = url else {
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            return nil
        }
        let options = HandyImage.setPlaceholder(to: view, options: options, other: other)
        let key = options.Cache.cacheCrypto.encryptedString(with: url.absoluteString)
        let object = Cached.shared.storage.fetchCached(forKey: key, options: options.Cache.cacheOption)
        if var data = object?.data {
            data = options.Cache.cacheDataZip.decompress(data: data)
            DispatchQueue.main.async {
                options.Network.progressBlock?(1.0)
                HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
            }
            return nil
        }
        let task = Networking.shared.addDownloadURL(url, progressBlock: options.Network.progressBlock, downloadBlock: { result in
            switch result {
            case .success(let res):
                DispatchQueue.main.async {
                    HandyImage.displayImage(data: res.data, to: view, filters: filters, options: options, other: other)
                }
                if res.downloadStatus == .complete {
                    let zipData = options.Cache.cacheDataZip.compressed(data: res.data)
                    let model = CacheModel(data: zipData)
                    Cached.shared.storage.storeCached(model, forKey: key, options: options.Cache.cacheOption)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    HandyImage.setPlaceholder(to: view, options: options, other: other)
                }
                options.Network.failed?(error)
            }
        }, retry: options.Network.retry, timeoutInterval: options.Network.timeoutInterval, interval: options.Network.downloadInterval)
        task.priority = options.Network.downloadPriority
        return Task(key: key, url: url, task: task)
    }
}

extension HandyImage {
    
    @discardableResult
    private static func setPlaceholder(to view: AsAnimatable, options: ImageXOptions, other: Others?) -> ImageXOptions {
        guard options.displayed == false else {
            return options
        }
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: view, contentMode: options.contentMode, other: other)
        return options
    }
    
    /// Fixed the setting  `options.contentMode` attributes cannot be filled and 尺寸获取失败的
    static func setViewContentMode(to view: AsAnimatable, options: ImageXOptions) -> ImageXOptions {
        if options.contentMode == .original {
            return options
        }
        #if !os(macOS)
        view.contentMode = .scaleAspectFit
        #endif
        if options.thumbnailPixelSize == .zero {
            #if !os(macOS)
            // Xib layout to get the size of the subviews.
            if view.frame.size == .zero {
                view.layoutSubviews()
            }
            // Automatic layout to get the size of the subviews.
            if view.frame.size == .zero {
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
            #else
            if view.frame.size == .zero {
                view.layoutSubtreeIfNeeded()
            }
            #endif
            var options_ = options
            options_.thumbnailPixelSize = view.frame.size
            return options_
        }
        return options
    }
}
