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
    
    static func displayImage<T>(source: T?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: Others?) {
        guard let source = source else {
            return
        }
        switch source {
        case let named as String:
            HandyImage.displayImage(named: named, to: view, filters: filters, options: options, other: other)
        case let data as Data:
            HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
        case let url as URL:
            HandyImage.displayImage(url: url, to: view, filters: filters, options: options, other: other)
        default:
            break
        }
    }
    
    static func displayImage(named: String?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: Others?) {
        guard let named = named, named.isEmpty == false else {
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            return
        }
        if R.verifyLink(named), let url = URL(string: named) {
            HandyImage.displayImage(url: url, to: view, filters: filters, options: options, other: other)
        } else {
            let options = HandyImage.setPlaceholder(to: view, options: options, other: other)
            if let data = R.gifData(named, forResource: options.moduleName) {
                HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
            } else if let image = R.image(named, forResource: options.moduleName) {
                HandyImage.setImage(image, to: view, filters: filters, options: options, other: other)
            }
        }
    }
    
    @discardableResult static func displayImage(
        data: Data?,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions,
        other: Others?
    ) -> AssetType {
        guard let data = data else {
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            return .unknow
        }
        let type = AssetType(data: data)
        handyData(data, type: type, to: view, filters: filters, options: options, other: other)
        return type
    }
    
    @discardableResult static func displayImage(
        url: URL?,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions,
        other: Others?
    ) -> Task? {
        guard let url = url else {
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            return nil
        }
        let options = HandyImage.setPlaceholder(to: view, options: options, other: other)
        let key = options.Network.cacheCrypto.encryptedString(with: url.absoluteString)
        if let object = Cached.shared.storage.fetchCached(forKey: key, options: options.Network.cacheOption), var data = object.data {
            data = options.Network.cacheDataZip.decompress(data: data)
            DispatchQueue.main.async {
                options.Network.progressBlock?(1.0)
                HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
            }
            return nil
        }
        let task = Networking.shared.addDownloadURL(url, progressBlock: options.Network.progressBlock, downloadBlock: { result in
            switch result {
            case .success(let res):
                switch res.downloadStatus {
                case .downloading:
                    guard res.type.canSetBrokenData else {
                        break
                    }
                    DispatchQueue.main.async {
                        HandyImage.handyData(res.data, type: res.type, to: view, filters: filters, options: options, other: other)
                    }
                case .complete:
                    DispatchQueue.main.async {
                        HandyImage.handyData(res.data, type: res.type, to: view, filters: filters, options: options, other: other)
                    }
                    let zipData = options.Network.cacheDataZip.compressed(data: res.data)
                    let model = CacheModel(data: zipData)
                    Cached.shared.storage.storeCached(model, forKey: key, options: options.Network.cacheOption)
                }
            case .failure(let error):
                options.Network.failed?(error)
                DispatchQueue.main.async {
                    HandyImage.setPlaceholder(to: view, options: options, other: other)
                }
            }
        }, retry: options.Network.retry, timeoutInterval: options.Network.timeoutInterval, interval: options.Network.downloadInterval)
        task.priority = options.Network.downloadPriority
        return Task(key: key, url: url, task: task)
    }
}

extension HandyImage {
    
    @discardableResult
    private static func setPlaceholder(to view: AsAnimatable, options: AnimatedOptions, other: Others?) -> AnimatedOptions {
        guard options.displayed == false else {
            return options
        }
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: view, contentMode: options.contentMode, other: other)
        return options
    }
    
    private static func setImage(_ image: C7Image?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: Others?) {
        if options.displayed == false {
            options.placeholder.display(to: view, contentMode: options.contentMode, other: other)
        }
        view.hasAnimator?.prepareForReuse()
        let size = options.confirmSize == .zero ? view.frame.size : options.confirmSize
        let resizeImage = options.contentMode.resizeImage(image, size: size)
        let dest = BoxxIO(element: resizeImage, filters: filters)
        if let outImage = try? dest.output() {
            switch options.placeholder {
            case .view:
                options.placeholder.remove(from: view, other: other)
            default:
                break
            }
            view.setContentImage(outImage, other: other)
        }
    }
    
    private static func handyData(_ data: Data,
                                  type: AssetType,
                                  to view: AsAnimatable,
                                  filters: [Harbeth.C7FilterProtocol],
                                  options: AnimatedOptions,
                                  other: Others?) {
        switch type {
        case .jpeg, .png, .tiff, .webp, .heic, .heif:
            let image = Harbeth.C7Image.init(data: data)
            HandyImage.setImage(image, to: view, filters: filters, options: options, other: other)
        case .gif:
            view.play(data: data, filters: filters, options: options, other: other)
        default:
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            view.hasAnimator?.prepareForReuse()
        }
    }
}
