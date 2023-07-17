//
//  AnimatedWebPCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct AnimatedWebPCoder: AnimatedImageCoder {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        .webp
    }
    
    public var unclampedDelayTimeProperty: String {
        if #available(iOS 14.0, tvOS 14, macOS 11, watchOS 7, *) {
            return String(kCGImagePropertyWebPUnclampedDelayTime)
        } else {
            return "UnclampedDelayTime"
        }
    }
    
    public var delayTimeProperty: String {
        if #available(iOS 14.0, tvOS 14, macOS 11, watchOS 7, *) {
            return String(kCGImagePropertyWebPDelayTime)
        } else {
            return "DelayTime"
        }
    }
    
    public var dictionaryProperty: String {
        if #available(iOS 14.0, tvOS 14, macOS 11, watchOS 7, *) {
            return String(kCGImagePropertyWebPDictionary)
        } else {
            return "{WebP}"
        }
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
}
