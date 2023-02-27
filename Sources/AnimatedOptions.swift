//
//  AnimatedOptions.swift
//  Wintersweet
//
//  Created by Condy on 2023/2/23.
//

import Foundation
import Harbeth

public typealias PreparationCallback = (() -> Void)
public typealias AnimatedCallback = ((_ loopDuration: TimeInterval) -> Void)
public typealias FailedCallback = ((_ error: Error?) -> Void)

/// Other parameters related to GIF playback.
/// Represents gif playback creating options used in Wintersweet.
public struct AnimatedOptions {
    
    public static let `default` = AnimatedOptions()
    
    internal var preparation: PreparationCallback?
    internal var animated: AnimatedCallback?
    private let placeholderImage: Harbeth.C7Image?
    
    /// Desired number of loops. Default  is ``forever``.
    public let loop: Wintersweet.Loop
    
    /// Content mode used for resizing the frames. Default is ``original``.
    public let contentMode: Wintersweet.ContentMode
    
    /// The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    public let bufferCount: Int
    
    /// Weather or not we should cache the URL response. Default  is ``disableMemoryCache``.
    public let cacheOption: Wintersweet.Cached.Options
    
    /// Placeholder image. default gray picture.
    public var placeholder: Harbeth.C7Image? {
        get {
            return placeholderImage ?? C7Color.gray.mt.colorImage(with: placeholderSize)
        }
    }
    /// Placeholder image size, default 100 x 100.
    public var placeholderSize: CGSize = CGSize(width: 100, height: 100)
    
    /// Instantiation of GIF configuration parameters.
    /// - Parameters:
    ///   - placeholder: Placeholder image. Default gray picture.
    ///   - loop: Desired number of loops. Default  is ``forever``.
    ///   - contentMode: Content mode used for resizing the frames. Default is ``original``.
    ///   - bufferCount: The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    ///   - cacheOption: Weather or not we should cache the URL response. Default  is ``disableMemoryCache``.
    public init(placeholder: C7Image? = nil, loop: Loop = .forever, contentMode: ContentMode = .original, bufferCount: Int = 50, cacheOption: Cached.Options = .disableMemoryCache) {
        self.loop = loop
        self.contentMode = contentMode
        self.bufferCount = bufferCount
        self.cacheOption = cacheOption
        self.placeholderImage = placeholder
    }
    
    /// Ready to play time callback.
    /// - Parameter block: Ready to play time response callback.
    public mutating func setPreparation(block: @escaping PreparationCallback) {
        self.preparation = block
    }
    
    /// Be played GIF.
    /// - Parameter block: Playback complete response callback.
    public mutating func setAnimated(block: @escaping AnimatedCallback) {
        self.animated = block
    }
}

extension AnimatedOptions {
    
    /// Load gif data.
    public static func gifData(_ named: String, forResource: String = "Wintersweet") -> Data? {
        let bundle: Bundle?
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: "bundle") {
            bundle = Bundle.init(path: bundlePath)
        } else {
            bundle = Bundle.main
        }
        guard let contentURL = ["gif", "GIF", "Gif"].compactMap({
            bundle?.url(forResource: named, withExtension: $0)
        }).first else {
            return nil
        }
        return try? Data(contentsOf: contentURL)
    }
}

extension AnimatedOptions {
    /// Load image resources
    static func image(_ named: String) -> C7Image? {
        let imageblock = { (name: String) -> C7Image? in
            return C7Image(named: named)
        }
        guard let bundlePath = Bundle.main.path(forResource: "Wintersweet", ofType: "bundle") else {
            return imageblock(named)
        }
        let bundle = Bundle.init(path: bundlePath)
        #if os(iOS) || os(tvOS) || os(watchOS)
        guard let image = C7Image(named: named, in: bundle, compatibleWith: nil) else {
            return imageblock(named)
        }
        return image
        #elseif os(macOS)
        guard let image = bundle?.image(forResource: named) else {
            return imageblock(named)
        }
        return image
        #endif
    }
}
