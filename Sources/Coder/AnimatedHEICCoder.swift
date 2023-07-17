//
//  AnimatedHEICCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct AnimatedHEICCoder: AnimatedImageCoder {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        .heic
    }
    
    public var unclampedDelayTimeProperty: String {
        if #available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *) {
            return String(kCGImagePropertyHEICSUnclampedDelayTime)
        } else {
            return "UnclampedDelayTime"
        }
    }
    
    public var delayTimeProperty: String {
        if #available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *) {
            return String(kCGImagePropertyHEICSDelayTime)
        } else {
            return "DelayTime"
        }
    }
    
    public var dictionaryProperty: String {
        if #available(iOS 13, tvOS 13, macOS 10.15, watchOS 6, *) {
            return String(kCGImagePropertyHEICSDictionary)
        } else {
            return "{HEICS}"
        }
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    public func canDecode() -> Bool {
        switch AssetType(data: data) {
        case .heic, .heif:
            return true
        default:
            return false
        }
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
