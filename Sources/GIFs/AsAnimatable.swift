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
    
    /// Prepare for animation and start play GIF.
    /// - Parameters:
    ///   - data: gif data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    ///   - other: Special parameters, such as the status of the button `UIControl.State`
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions, other: AnimatedOthers?)
}

extension AsAnimatable {
    /// Prepare for animation and start play GIF.
    public func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions) {
        self.play(data: data, filters: filters, options: options, other: nil)
    }
    
    /// Prepare for animation and start play GIF.
    public func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions, other: AnimatedOthers?) {
        if options.displayed == false {
            options.placeholder.display(to: self, contentMode: options.contentMode, other: other)
        }
        guard let data = data, AssetType(data: data) == .gif else { return }
        let size = options.confirmSize == .zero ? frame.size : options.confirmSize
        let frameStore = FrameStore(data: data,
                                    filters: filters,
                                    size: size,
                                    framePreloadCount: options.bufferCount,
                                    contentMode: options.contentMode,
                                    loopCount: options.loop.count)
        frameStore.prepareFrames { [weak self] in
            guard let `self` = self else { return }
            if case .fristFrame = options.loop {
                if let frame = frameStore.animatedFrames.compactMap({ $0.image }).first {
                    options.placeholder.remove(from: self, other: other)
                    self.setContentImage(frame, other: other)
                }
            } else if case .lastFrame = options.loop {
                if let frame = frameStore.animatedFrames.compactMap({ $0.image }).last {
                    options.placeholder.remove(from: self, other: other)
                    self.setContentImage(frame, other: other)
                }
            } else {
                options.placeholder.remove(from: self, other: other)
            }
            options.preparation?()
        }
        animator?.other = other
        animator?.frameStore = frameStore
        animator?.animationBlock = options.animated
        switch options.loop {
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
    func updateImageIfNeeded(other: AnimatedOthers?) {
        guard let activeFrame = activeFrame else {
            return
        }
        setContentImage(activeFrame, other: other)
    }
    
    /// Setting up what is currently showing.
    @inline(__always) func setContentImage(_ image: C7Image?, other: AnimatedOthers?) {
        switch self {
        case var imageContainer as ImageContainer:
            imageContainer.image = image
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        case var buttonContainer as NSButtonContainer:
            guard let other = other else {
                return
            }
            switch AnimatedOthers.NSButtonKey(rawValue: other.key) {
            case .none:
                break
            case .image:
                buttonContainer.image = image
            case .alternateImage:
                buttonContainer.alternateImage = image
            }
        #endif
        #if canImport(UIKit) && !os(watchOS)
        case var buttonContainer as UIButtonContainer:
            guard let other = other else {
                return
            }
            switch AnimatedOthers.ButtonKey(rawValue: other.key) {
            case .none:
                break
            case .image:
                if let state = other.value as? UIControl.State {
                    buttonContainer.setImage(image, for: state)
                    let (_, backImage) = buttonContainer.cacheImages[state.rawValue] ?? (nil, nil)
                    buttonContainer.cacheImages[state.rawValue] = (image, backImage)
                }
            case .backgroundImage:
                if let state = other.value as? UIControl.State {
                    buttonContainer.setBackgroundImage(image, for: state)
                    let (image_, _) = buttonContainer.cacheImages[state.rawValue] ?? (nil, nil)
                    buttonContainer.cacheImages[state.rawValue] = (image_, image)
                }
            }
        #endif
        default:
            #if !os(macOS)
            //self.layer.setNeedsDisplay()
            self.layer.contents = image?.cgImage
            #endif
        }
    }
}
