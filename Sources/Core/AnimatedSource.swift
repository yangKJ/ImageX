//
//  AnimatedSource.swift
//  ImageX
//
//  Created by Condy on 2023/7/14.
//

import Foundation
import ImageIO

struct AnimatedSource {
    
    /// A uniform type identifier UTI.
    let type: AssetType
    
    /// The raw data received from downloader.
    let data: Data
    
    /// A reference to the original image source.
    let imageSource: CGImageSource
    
    /// The total number of frames in the GIF.
    let frameCount: Int
}

extension AnimatedSource {
    
    /// Return whether the image source is a dynamic resource.
    public var isAnimated: Bool {
        frameCount > 1
    }
    
    static func createAnimatedSource(_ data: Data, type: AssetType? = nil) -> AnimatedSource {
        let options = [
            String(kCGImageSourceShouldCache): kCFBooleanFalse,
        ] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(data as CFData, options) ?? CGImageSourceCreateIncremental(options)
        let frameCount = Int(CGImageSourceGetCount(imageSource))
        let type = type ?? AssetType(data: data)
        return AnimatedSource(type: type, data: data, imageSource: imageSource, frameCount: frameCount)
    }
}
