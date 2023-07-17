//
//  ImageIOCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct ImageIOCoder: ImageCoder {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        AssetType(data: data)
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    public func decodedCGImage(options: ImageCoderOptions, index: Int) -> CGImage? {
        self.imageSource?.mt.toCGImage(index: index)
    }
}
