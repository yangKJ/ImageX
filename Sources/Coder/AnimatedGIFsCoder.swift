//
//  AnimatedGIFsCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct AnimatedGIFsCoder: AnimatedImageCoder {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        .gif
    }
    
    public var unclampedDelayTimeProperty: String {
        String(kCGImagePropertyGIFUnclampedDelayTime)
    }
    
    public var delayTimeProperty: String {
        String(kCGImagePropertyGIFDelayTime)
    }
    
    public var dictionaryProperty: String {
        String(kCGImagePropertyGIFDictionary)
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    public static func encodeImage(_ image: Harbeth.C7Image, options: ImageCoderOptions) -> Data? {
        return nil
    }
}
