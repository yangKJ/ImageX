//
//  AsAnimatable.swift
//  ImageX
//
//  Created by Condy on 2023/1/5.
//  Reference source See: https://github.com/kean/Nuke/tree/master/Sources/NukeUI/Gifu

import Foundation
import Harbeth

public typealias TimeInterval = Foundation.TimeInterval

/// The protocol that view classes need to conform to to enable animated GIF support.
public protocol AsAnimatable: HasAnimatable {
    
    /// Total duration of one animation loop.
    var loopDuration: TimeInterval { get }
    
    /// The first frame that is not nil of GIF.
    var fristFrame: C7Image? { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the GIF.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimatingGIF: Bool { get }
    
    /// Bitmap memory cost with bytes.
    var costGIF: Int { get }
    
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
    ///   - options: Represents creating options used in ImageX.
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions)
}

extension AsAnimatable {
    /// Prepare for animation and start play GIF.
    public func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions) {
        guard let data = data, AssetType(data: data) == .gif else {
            if options.displayed == false {
                options.placeholder.display(to: self, contentMode: options.contentMode, other: nil)
            }
            return
        }
        let source = AnimatedSource.createAnimatedSource(data)
        self.play(source: source, filters: filters, options: options, other: nil)
    }
    
    /// Prepare for animation and start play GIF.
    func play(source: AnimatedSource, filters: [C7FilterProtocol], options: ImageX.AnimatedOptions, other: ImageX.Others?) {
        if options.displayed == false {
            options.placeholder.display(to: self, contentMode: options.contentMode, other: other)
        }
        let size = options.confirmSize == .zero ? frame.size : options.confirmSize
        let frameStore = FrameStore(source: source,
                                    filters: filters,
                                    size: size,
                                    framePreloadCount: options.GIFs.bufferCount,
                                    contentMode: options.contentMode,
                                    loopCount: options.GIFs.loop.count,
                                    prepare: { (store) in
            if let preparation = options.GIFs.preparation {
                let res = GIFResponse(data: source.data,
                                      animatedFrames: store.animatedFrames,
                                      loopDuration: store.loopDuration,
                                      fristFrame: store.fristFrame,
                                      activeFrame: store.currentFrameImage,
                                      frameCount: store.frameCount,
                                      isAnimatingGIF: store.isAnimatable,
                                      costGIF: store.cost)
                preparation(res)
            }
        })
        animator?.options = options
        animator?.other = other
        animator?.frameStore = frameStore
        animator?.animationBlock = options.GIFs.animated
        switch options.GIFs.loop {
        case .forever, .never, .count:
            animator?.startAnimating()
        }
    }
}

extension AsAnimatable {
    public var loopDuration: TimeInterval { animator?.frameStore?.loopDuration ?? 0 }
    public var fristFrame: C7Image? { animator?.frameStore?.fristFrame }
    public var activeFrame: C7Image? { animator?.frameStore?.currentFrameImage }
    public var frameCount: Int { animator?.frameStore?.frameCount ?? 0 }
    public var isAnimatingGIF: Bool { animator?.isAnimating ?? false }
    public var costGIF: Int { animator?.frameStore?.cost ?? 0 }
    public func prepareForReuseGIF() { animator?.prepareForReuse() }
    public func startAnimatingGIF() { animator?.startAnimating() }
    public func stopAnimatingGIF() { animator?.stopAnimating() }
}

extension AsAnimatable {
    /// Updates the image with a new frame if necessary.
    func updateImageIfNeeded(other: Others?) {
        guard let activeFrame = activeFrame else {
            return
        }
        setContentImage(activeFrame, other: other)
    }
}
