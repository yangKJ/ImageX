//
//  AsAnimatable.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/5.
//  Reference source See: https://github.com/kean/Nuke/tree/master/Sources/NukeUI/Gifu

import Foundation
@_exported import Harbeth

public typealias HFilter = Harbeth.C7FilterProtocol
public typealias TimeInterval = Foundation.TimeInterval
public typealias PreparationCallback = (() -> Void)
public typealias AnimatedCallback = ((_ loopDuration: TimeInterval) -> Void)
public typealias FailedCallback = ((_ error: Error?) -> Void)

/// The protocol that view classes need to conform to to enable animated GIF support.
public protocol AsAnimatable: HasAnimatable {    
    /// Total duration of one animation loop
    var loopDuration: TimeInterval { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the GIF.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimatingGIF: Bool { get }
    
    /// Compute frame size for this gif.
    var gifSize: Int { get }
    
    /// Stop animating and free up GIF data from memory.
    func prepareForReuseGIF()
    
    /// Start animating GIF.
    func startAnimatingGIF()
    
    /// Stop animating GIF.
    func stopAnimatingGIF()
}

extension AsAnimatable {
    
    /// Prepare for animation and start play GIF.
    /// - Parameters:
    ///   - GIFData: GIF image data.
    ///   - filters: Harbeth filters apply to GIF frame.
    ///   - loop: Desired number of loops. Default  is ``forever``.
    ///   - contentMode: Content mode used for resizing the frames. Default is ``original``.
    ///   - bufferCount: The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    ///   - preparation: Ready to play time callback.
    ///   - animated: Be played GIF.
    public func play(withGIFData data: Data,
                     filters: [HFilter],
                     loop: Wintersweet.Loop = .forever,
                     contentMode: Wintersweet.ContentMode = .original,
                     bufferCount: Int = 50,
                     preparation: PreparationCallback? = nil,
                     animated: AnimatedCallback? = nil) {
        guard AssetType(data: data) == .gif else { return }
        let frameStore = FrameStore(data: data, filters: filters, size: frame.size, framePreloadCount: bufferCount, contentMode: contentMode, loopCount: loop.count)
        frameStore.prepareFrames { preparation?() }
        animator?.frameStore = frameStore
        animator?.animationBlock = animated
        animator?.startAnimating()
    }
    
    /// Prepare for animation and start play GIF.
    /// - Parameters:
    ///   - GIFURL: GIF image url.
    ///   - filters: Harbeth filters apply to GIF frame.
    ///   - loop: Desired number of loops. Default  is ``forever``.
    ///   - contentMode: Content mode used for resizing the frames. Default is ``original``.
    ///   - cacheOption: Weather or not we should cache the URL response. Default  is ``disableMemoryCache``.
    ///   - bufferCount: The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    ///   - preparation: Ready to play time callback.
    ///   - animated: Be played GIF.
    ///   - failed: Network failure callback.
    public func play(withGIFURL: URL,
                     filters: [HFilter],
                     loop: Wintersweet.Loop = .forever,
                     contentMode: Wintersweet.ContentMode = .original,
                     cacheOption: Wintersweet.Cached.Options = .disableMemoryCache,
                     bufferCount: Int = 50,
                     preparation: PreparationCallback? = nil,
                     animated: AnimatedCallback? = nil,
                     failed: FailedCallback? = nil) {
        let makeCacheKey = { () -> AnyObject in withGIFURL as AnyObject }
        if let data: Data = cacheOption.read(key: makeCacheKey()) {
            self.play(withGIFData: data, filters: filters, loop: loop, contentMode: contentMode, bufferCount: bufferCount, preparation: preparation, animated: animated)
            return
        }
        let task = URLSession.shared.dataTask(with: withGIFURL) { (data, _, error) in
            guard AssetType(data: data) == .gif else {
                let error = NSError(domain: "WintersweetErrorDomain", code: 520, userInfo: [
                    NSLocalizedDescriptionKey: "The network link address is not a gif."
                ])
                failed?(error)
                return
            }
            switch (data, error) {
            case (.none, let error):
                failed?(error)
            case (let data?, _):
                DispatchQueue.main.async {
                    self.play(withGIFData: data, filters: filters, loop: loop, contentMode: contentMode, bufferCount: bufferCount, preparation: preparation, animated: animated)
                }
                cacheOption.write(key: makeCacheKey(), value: data as NSData)
            }
        }
        task.resume()
    }
    
    /// Updates the image with a new frame if necessary.
    public func updateImageIfNeeded() {
        if var imageContainer = self as? ImageContainer {
            let container = imageContainer
            imageContainer.image = activeFrame ?? container.image
        } else {
            #if !os(macOS)
            //layer.setNeedsDisplay()
            layer.contents = activeFrame?.cgImage
            #endif
        }
    }
}

extension AsAnimatable {
    public var loopDuration: TimeInterval { return animator?.frameStore?.loopDuration ?? 0 }
    public var activeFrame: C7Image? { return animator?.frameStore?.currentFrameImage }
    public var frameCount: Int { return animator?.frameStore?.frameCount ?? 0 }
    public var isAnimatingGIF: Bool { return animator?.isAnimating ?? false }
    public var gifSize: Int {
        guard let image = activeFrame else { return 0 }
        return Int(image.size.height * image.size.width * 4) * frameCount / 1_000_000
    }
    public func prepareForReuseGIF() { animator?.prepareForReuse() }
    public func startAnimatingGIF() { animator?.startAnimating() }
    public func stopAnimatingGIF() { animator?.stopAnimating() }
}
