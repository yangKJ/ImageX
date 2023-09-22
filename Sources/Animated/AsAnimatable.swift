//
//  AsAnimatable.swift
//  ImageX
//
//  Created by Condy on 2023/1/5.
//  Reference source See: https://github.com/kean/Nuke/tree/master/Sources/NukeUI/Gifu

import Foundation
import Harbeth

public typealias TimeInterval = Foundation.TimeInterval

/// The protocol that view classes need to conform to to enable animated images support.
public protocol AsAnimatable: HasAnimatable {
    
    /// Total duration of one animation loop.
    var loopDuration: TimeInterval { get }
    
    /// The first frame that is not nil of animated images.
    var fristFrame: C7Image? { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the animated images.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimating: Bool { get }
    
    /// Bitmap memory cost with bytes.
    var cost: Int { get }
    
    /// Stop animating and free up animated images data from memory.
    func prepareForReuse()
    
    /// Start animating animated image.
    func startAnimating()
    
    /// Stop animating animated image.
    func stopAnimating()
    
    /// Prepare for animation and start play animated image.
    /// - Parameters:
    ///   - data: gif data.
    ///   - filters: Harbeth filters apply to image or animated image frame.
    ///   - options: Represents animated image playback creating options used in ImageX.
    func play(data: Data?, filters: [C7FilterProtocol], options: ImageXOptions)
}

extension AsAnimatable {
    
    /// Prepare for animation and start play animated images.
    public func play(data: Data?, filters: [C7FilterProtocol], options: ImageXOptions) {
        let options_ = Driver.setViewContentMode(to: self, options: options)
        let options = Driver.setPlaceholder(to: self, options: options_, other: nil)
        if let decoder = Driver.fetchDecoder(data: data, options: options) as? AnimatedCodering {
            self.play(decoder: decoder, filters: filters, options: options, other: nil)
        }
    }
    
    /// Prepare for animation and start play animated images.
    func play(decoder: AnimatedCodering, filters: [C7FilterProtocol], options: ImageXOptions, other: Others?) {
        let options_ = Driver.setViewContentMode(to: self, options: options)
        let options = Driver.setPlaceholder(to: self, options: options_, other: nil)
        let store = FrameStore(decoder: decoder, filters: filters, options: options) { [weak self] _ in
            guard let weakself = self else {
                return
            }
            weakself.animator?.startAnimating()
            switch options.placeholder {
            case .view:
                options.placeholder.remove(from: weakself, other: other)
            default:
                break
            }
        }
        animator?.frameStore = store
        animator?.options = options
        animator?.other = other
        animator?.animationBlock = options.Animated.animated
    }
}

extension AsAnimatable {
    
    public var loopDuration: TimeInterval {
        animator?.frameStore?.loopDuration ?? 0
    }
    
    public var fristFrame: C7Image? {
        animator?.frameStore?.fristFrame
    }
    
    public var activeFrame: C7Image? {
        animator?.frameStore?.currentFrameImage
    }
    
    public var frameCount: Int {
        animator?.frameStore?.frameCount ?? 0
    }
    
    public var isAnimating: Bool {
        animator?.isAnimating ?? false
    }
    
    public var cost: Int {
        animator?.frameStore?.cost ?? 0
    }
    
    public func prepareForReuse() {
        animator?.prepareForReuse()
    }
    
    public func startAnimating() {
        animator?.startAnimating()
    }
    
    public func stopAnimating() {
        animator?.stopAnimating()
    }
}
