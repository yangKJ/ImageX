//
//  Driver.swift
//  ImageX
//
//  Created by Condy on 2023/6/29.
//

import Foundation
import Harbeth
import CacheX

struct Driver {
    
    static func setImage(named: String?, to view: AsAnimatable, filters: [C7FilterProtocol], options: ImageXOptions, other: Others?) {
        guard let named = named, named.isEmpty == false else {
            view.hasAnimator?.prepareForReuse()
            Driver.setPlaceholder(to: view, options: options, other: other)
            return
        }
        let options = Driver.setPlaceholder(to: view, options: options, other: other)
        if R.verifyLink(named), let url = URL(string: named) {
            Driver.setImage(url: url, to: view, filters: filters, options: options, other: other)
        } else if let data = R.gifData(named, forResource: options.moduleName) {
            Driver.setImage(data: data, to: view, filters: filters, options: options, other: other)
        } else if let image = R.image(named, forResource: options.moduleName) {
            view.hasAnimator?.prepareForReuse()
            let options = Driver.setViewContentMode(to: view, options: options)
            let reimage = options.resizingMode.resizeImage(image, size: options.thumbnailPixelSize)
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
    
    @discardableResult static func setImage(
        data: Data?,
        to view: AsAnimatable,
        finished: Bool = true,
        filters: [Harbeth.C7FilterProtocol],
        options: ImageXOptions,
        other: Others?
    ) -> AssetType {
        view.hasAnimator?.prepareForReuse()
        let options_ = Driver.setViewContentMode(to: view, options: options)
        let options = Driver.setPlaceholder(to: view, options: options_, other: other)
        guard let data = data else {
            return .unknow
        }
        let decoder = fetchDecoder(data: data, options: options)
        if options.Animated.frameType == .animated, let decoder = decoder as? AnimatedCodering, decoder.isAnimatedImages() {
            view.play(decoder: decoder, filters: filters, options: options, other: other)
        } else {
            let coderOptions = options.setupDecoderOptions(filters, finished: finished)
            decoder?.decodedImage(options: coderOptions, onNext: { image in
                guard let image = image else {
                    return
                }
                view.setContentImage(image, other: other)
            })
        }
        return decoder?.format ?? AssetType.unknow
    }
    
    @discardableResult static func setImage(
        url: URL?,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: ImageXOptions,
        other: Others?
    ) -> ImageX.Task? {
        guard let url = url else {
            Driver.setPlaceholder(to: view, options: options, other: other)
            return nil
        }
        let options = Driver.setPlaceholder(to: view, options: options, other: other)
        let key = options.Cache.cacheCrypto.encryptedString(with: url.absoluteString)
        if var data = Cached.shared.storage.read(key: key, options: options.Cache.cacheOption) {
            data = options.Cache.cacheDataZip.decompress(data: data)
            DispatchQueue.main.async {
                options.Network.progressBlock?(1.0)
                Driver.setImage(data: data, to: view, filters: filters, options: options, other: other)
            }
            return nil
        }
        let task = Networking.shared.addDownloadURL(url, options: options, downloadBlock: { result in
            switch result {
            case .success(let res):
                DispatchQueue.main.async {
                    let finished = res.downloadStatus == .complete ? true : false
                    Driver.setImage(data: res.data, to: view, finished: finished, filters: filters, options: options, other: other)
                }
                if res.downloadStatus == .complete {
                    let zipData = options.Cache.cacheDataZip.compressed(data: res.data)
                    Cached.shared.storage.write(key: key, value: zipData, options: options.Cache.cacheOption)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    Driver.setPlaceholder(to: view, options: options, other: other)
                }
                options.Network.failed?(error)
            }
        })
        task.priority = options.Network.downloadPriority
        return ImageX.Task(key: key, url: url, task: task)
    }
}

extension Driver {
    
    @discardableResult static func setPlaceholder(to view: AsAnimatable, options: ImageXOptions, other: Others?) -> ImageXOptions {
        guard options.displayed == false else {
            return options
        }
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: view, resizingMode: options.resizingMode, other: other)
        return options
    }
    
    /// Fixed the setting  `options.resizingMode` attributes cannot be filled.
    static func setViewContentMode(to view: AsAnimatable, options: ImageXOptions) -> ImageXOptions {
        if options.resizingMode == .original {
            return options
        }
        #if canImport(UIKit)
        view.contentMode = .scaleAspectFit
        #endif
        if options.thumbnailPixelSize == .zero {
            let realsize = realViewFrame(to: view).size
            return options.mutating({ $0.thumbnailPixelSize = realsize })
        }
        return options
    }
    
    /// Get the real frame of the view.
    @discardableResult static func realViewFrame(to view: AsAnimatable) -> CGRect {
        guard view.frame == .zero else {
            return view.frame
        }
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
        return view.frame
    }
    
    static func fetchDecoder(data: Data?, options: ImageXOptions) -> ImageCodering? {
        guard let data = data else {
            return nil
        }
        if var appointCoder = options.appointCoder {
            appointCoder.data = data
            appointCoder.setupImageSource(data: data)
            return appointCoder
        } else {
            let format = AssetType(data: data)
            switch format {
            case .jpeg:
                return ImageJPEGCoder.init(data: data)
            case .png:
                return AnimatedAPNGCoder.init(data: data)
            case .gif:
                return AnimatedGIFsCoder.init(data: data)
            case .webp:
                return AnimatedWebPCoder.init(data: data)
            case .heif, .heic:
                return AnimatedHEICCoder.init(data: data)
            case .tiff, .raw, .pdf, .bmp, .svg:
                return ImageIOCoder.init(data: data, format: format)
            default:
                return nil
            }
        }
    }
}
