//
//  ImageCodering.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import ObjectiveC
import ImageIO
import Harbeth
#if canImport(MobileCoreServices)
@_exported import MobileCoreServices
#endif

/// Set up encode or decode to still image.
public protocol ImageCodering {
    
    typealias ImageCoderOptions = [String: Any]
    
    /// The supported image format.
    var format: AssetType { get }
    
    /// A uniform type identifier UTI.
    var imageUTType: String { get }
    
    /// The image data to be decoded
    var data: Data { get set }
    
    /// The original image source.
    var imageSource: CGImageSource? { get set }
    
    /// Total number animated frames.
    var frameCount: Int { get set }
    
    /// Initialization an coder decoding object.
    /// - Parameter data: The data to be decoded
    init(data: Data)
    
    /// Initialization an coder decoding object.
    /// - Parameters:
    ///   - data: The data to be decoded
    ///   - dataOptions: The dictionary may be used to request additional creation options.
    init(data: Data, dataOptions: CFDictionary)
    
    /// Is it a animated images resource?
    func isAnimatedImages() -> Bool
    
    /// Returns YES if this coder can decode some data. Otherwise, the data should be passed to another coder.
    func canDecode() -> Bool
    
    /// Can it be progressive displayed incrementally.
    func progressive() -> Bool
    
    /// Real time decoder of incomplete data.
    func canDecoderBrokenData() -> Bool
    
    /// Decode the data to CGImage.
    /// - Parameters:
    ///   - options: A dictionary containing any decoding options.
    ///   - index: The index of the frame to load.
    /// - Returns: The decoded CGImage from data.
    func decodedCGImage(options: ImageCoderOptions, index: Int) -> CGImage?
    
    // MARK: - encoder
    
    /// Encode the image to data.
    /// - Parameters:
    ///   - image: The image to be encoded.
    ///   - options: A dictionary containing any encoding options.
    /// - Returns: The encoded image data
    static func encodeImage(_ image: C7Image, options: ImageCoderOptions) -> Data?
}

extension ImageCodering {
    
    public init(data: Data) {
        let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
        self.init(data: data, dataOptions: options)
    }
    
    public var imageUTType: String {
        format.rawValue
    }
    
    public func canDecode() -> Bool {
        //AssetType(data: data) == format
        return true
    }
    
    public func isAnimatedImages() -> Bool {
        return frameCount > 1
    }
    
    public func progressive() -> Bool {
        return false
    }
    
    public func canDecoderBrokenData() -> Bool {
        return false
    }
    
    public func decodedCGImage(options: ImageCoderOptions, index: Int) -> CGImage? {
        guard canDecode(), let imageSource = self.imageSource else {
            return nil
        }
        return imageSource.mt.toCGImage(index: index)
    }
}

extension ImageCodering {
    
    /// Set up the original image source and total number animated frames.
    mutating func setupImageSource(data: Data, dataOptions: CFDictionary) {
        if !data.isEmpty, let imageSource = CGImageSourceCreateWithData(data as CFData, dataOptions) {
            self.frameCount = Int(CGImageSourceGetCount(imageSource))
            self.imageSource = imageSource
        } else {
            self.frameCount = 0
            self.imageSource = nil
        }
    }
    
    /// Decode the data to image.
    /// - Parameter options: A dictionary containing any decoding options.
    /// - Returns: The decoded image from data.
    func decodedImage(options: ImageCoderOptions) -> Harbeth.C7Image? {
        guard canDecode() else {
            return nil
        }
        let frameType = options[ImageCoderOption.decoder.frameTypeKey] as? FrameType ?? .animated
        if frameType == .animated, isAnimatedImages(), !canDecoderBrokenData() {
            return nil
        }
        let index = frameType.index(frameCount)
        let filters = options[ImageCoderOption.decoder.filtersKey] as? [C7FilterProtocol] ?? []
        var image: Harbeth.C7Image?
        if let cgImage = decodedCGImage(options: options, index: index) {
            let dest = BoxxIO(element: cgImage, filters: filters)
            image = try? dest.output().mt.toC7Image()
        } else {
            let dest = BoxxIO(element: Harbeth.C7Image(data: data), filters: filters)
            image = try? dest.output()
        }
        if let resize = options[ImageCoderOption.decoder.thumbnailPixelSizeKey] as? CGSize,
           let resizingMode = options[ImageCoderOption.decoder.resizingModeKey] as? ResizingMode {
            image = resizingMode.resizeImage(image, size: resize)
        }
        return image
    }
}
