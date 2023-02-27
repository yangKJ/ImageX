//
//  AsAnimatable.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/5.
//  Reference source See: https://github.com/kean/Nuke/tree/master/Sources/NukeUI/Gifu

import Foundation
@_exported import Harbeth

public typealias TimeInterval = Foundation.TimeInterval

/// The protocol that view classes need to conform to to enable animated GIF support.
public protocol AsAnimatable: HasAnimatable {
    
    /// Total duration of one animation loop
    var loopDuration: TimeInterval { get }
    
    /// The first frame of the current GIF.
    var fristFrame: C7Image? { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the GIF.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimatingGIF: Bool { get }
    
    /// Bitmap memory cost with bytes.
    var cost: Int { get }
    
    /// Stop animating and free up GIF data from memory.
    func prepareForReuseGIF()
    
    /// Start animating GIF.
    func startAnimatingGIF()
    
    /// Stop animating GIF.
    func stopAnimatingGIF()
    
    /// Prepare for animation and start play GIF.
    /// - Parameters:
    ///   - data: gif data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in Wintersweet.
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions)
}

extension AsAnimatable {
    /// Prepare for animation and start play GIF.
    public func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions) {
        guard let data = data, AssetType(data: data) == .gif else { return }
        let frameStore = FrameStore(data: data,
                                    filters: filters,
                                    size: frame.size,
                                    framePreloadCount: options.bufferCount,
                                    contentMode: options.contentMode,
                                    loopCount: options.loop.count)
        frameStore.prepareFrames { options.preparation?() }
        animator?.frameStore = frameStore
        animator?.animationBlock = options.animated
        animator?.startAnimating()
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
    public var fristFrame: C7Image? { return animator?.frameStore?.animatedFrames.first?.image }
    public var activeFrame: C7Image? { return animator?.frameStore?.currentFrameImage }
    public var frameCount: Int { return animator?.frameStore?.frameCount ?? 0 }
    public var isAnimatingGIF: Bool { return animator?.isAnimating ?? false }
    public var cost: Int {
        guard let image = activeFrame else { return 0 }
        return Int(image.size.height * image.size.width * 4) * frameCount / 1_000_000
    }
    public func prepareForReuseGIF() { animator?.prepareForReuse() }
    public func startAnimatingGIF() { animator?.startAnimating() }
    public func stopAnimatingGIF() { animator?.stopAnimating() }
}
