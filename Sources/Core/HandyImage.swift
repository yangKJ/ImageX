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
    
    static func displayImage<T>(source: T?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: AnimatedOthers?) {
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
    
    static func displayImage(named: String?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: AnimatedOthers?) {
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
        other: AnimatedOthers?
    ) -> AssetType {
        let type = AssetType(data: data)
        switch type {
        case .jpeg, .png, .tiff, .webp, .heic, .heif:
            let image = Harbeth.C7Image.init(data: data!)
            HandyImage.setImage(image, to: view, filters: filters, options: options, other: other)
        case .gif:
            view.play(data: data, filters: filters, options: options, other: other)
        default:
            HandyImage.setPlaceholder(to: view, options: options, other: other)
            view.hasAnimator?.prepareForReuse()
        }
        return type
    }
    
    @discardableResult static func displayImage(
        url: URL,
        to view: AsAnimatable,
        filters: [Harbeth.C7FilterProtocol],
        options: AnimatedOptions,
        other: AnimatedOthers?
    ) -> URLSessionDataTask? {
        let options = HandyImage.setPlaceholder(to: view, options: options, other: other)
        let key = options.cacheCrypto.encryptedString(with: url.absoluteString)
        if let object = Cached.shared.storage.fetchCached(forKey: key, options: options.cacheOption), var data = object.data {
            data = options.cacheDataZip.decompress(data: data)
            HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
            return nil
        }
        return Networking.shared.addDownloadURL(url, retry: options.retry) { (data, response, error) in
            switch (data, error) {
            case (.none, let error):
                options.failed?(response, error)
                DispatchQueue.main.async {
                    HandyImage.setPlaceholder(to: view, options: options, other: other)
                }
            case (let data?, _):
                DispatchQueue.main.async {
                    HandyImage.displayImage(data: data, to: view, filters: filters, options: options, other: other)
                }
                let zipData = options.cacheDataZip.compressed(data: data)
                let model = CacheModel(data: zipData)
                Cached.shared.storage.storeCached(model, forKey: key, options: options.cacheOption)
            }
        }
    }
}

extension HandyImage {
    
    @discardableResult
    private static func setPlaceholder(to view: AsAnimatable, options: AnimatedOptions, other: AnimatedOthers?) -> AnimatedOptions {
        guard options.displayed == false else {
            return options
        }
        let options = options.setDisplayed(placeholder: true)
        options.placeholder.display(to: view, contentMode: options.contentMode, other: other)
        return options
    }
    
    private static func setImage(_ image: C7Image?, to view: AsAnimatable, filters: [C7FilterProtocol], options: AnimatedOptions, other: AnimatedOthers?) {
        if options.displayed == false {
            options.placeholder.display(to: view, contentMode: options.contentMode, other: other)
        }
        view.hasAnimator?.prepareForReuse()
        let size = options.confirmSize == .zero ? view.frame.size : options.confirmSize
        let resizeImage = options.contentMode.resizeImage(image, size: size)
        let dest = BoxxIO(element: resizeImage, filters: filters)
        if let outImage = try? dest.output() {
            options.placeholder.remove(from: view, other: other)
            view.setContentImage(outImage, other: other)
        }
    }
}
