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
    ///   - options: Represents gif playback creating options used in ImageX.
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions)
}

extension AsAnimatable {
    /// Prepare for animation and start play GIF.
    public func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions) {
        self.play(data: data, filters: filters, options: options, other: nil)
    }
    
    /// Prepare for animation and start play GIF.
    func play(data: Data?, filters: [C7FilterProtocol], options: ImageX.AnimatedOptions, other: ImageX.Others?) {
        if options.displayed == false {
            options.placeholder.display(to: self, contentMode: options.contentMode, other: other)
        }
        guard let data = data, AssetType(data: data) == .gif else { return }
        let size = options.confirmSize == .zero ? frame.size : options.confirmSize
        let frameStore = FrameStore(data: data,
                                    filters: filters,
                                    size: size,
                                    framePreloadCount: options.GIFs.bufferCount,
                                    contentMode: options.contentMode,
                                    loopCount: options.GIFs.loop.count,
                                    prepare: { [weak self] (store) in
            guard let `self` = self else { return }
            if case .fristFrame = options.GIFs.loop {
                if let frame = store.animatedFrames.compactMap({ $0.image }).first {
                    switch options.placeholder {
                    case .view:
                        options.placeholder.remove(from: self, other: other)
                    default:
                        break
                    }
                    self.setContentImage(frame, other: other)
                }
            } else if case .lastFrame = options.GIFs.loop {
                if let frame = store.animatedFrames.compactMap({ $0.image }).last {
                    switch options.placeholder {
                    case .view:
                        options.placeholder.remove(from: self, other: other)
                    default:
                        break
                    }
                    self.setContentImage(frame, other: other)
                }
            } else {
                switch options.placeholder {
                case .view:
                    options.placeholder.remove(from: self, other: other)
                default:
                    break
                }
            }
            if let preparation = options.GIFs.preparation {
                let res = GIFResponse(data: data,
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
        case .fristFrame, .lastFrame:
            animator?.stopAnimating()
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
