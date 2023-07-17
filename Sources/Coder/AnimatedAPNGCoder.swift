//
//  AnimatedAPNGCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct AnimatedAPNGCoder: AnimatedImageCoder {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        .png
    }
    
    public var unclampedDelayTimeProperty: String {
        String(kCGImagePropertyAPNGUnclampedDelayTime)
    }
    
    public var delayTimeProperty: String {
        String(kCGImagePropertyAPNGDelayTime)
    }
    
    public var dictionaryProperty: String {
        String(kCGImagePropertyPNGDictionary)
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    public func decodedCGImage(options: ImageCoderOptions, index: Int) -> CGImage? {
        guard canDecode() else {
            return nil
        }
        return self.imageSource?.mt.toCGImage(index: index)
    }
    
    public func decodeAnimatedCGImage(options: ImageCoderOptions, indexes: [Int]) -> [CGImage?] {
        guard canDecode(), isAnimatedImages(), let imageSource = imageSource else {
            return []
        }
        var cgImages = [CGImage?]()
        for index in indexes where index >= 0 && index <= frameCount {
            let cgImage = CGImageSourceCreateImageAtIndex(imageSource, index, nil)
            cgImages.append(cgImage)
        }
        return cgImages
    }
    
    public static func encodeImage(_ image: Harbeth.C7Image, options: ImageCoderOptions) -> Data? {
        #if os(macOS)
        guard let cgImage = image.cgImage else {
            return nil
        }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .png, properties: [:])
        #else
        return image.pngData()
        #endif
    }
}
