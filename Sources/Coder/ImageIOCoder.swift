//
//  ImageIOCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

/// Support still image format, such as `.tiff, .raw, .pdf, .bmp, .svg`
public struct ImageIOCoder: ImageCodering {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        self.type ?? AssetType(data: data)
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    private var type: AssetType?
    
    public init(data: Data, format: AssetType) {
        self.init(data: data)
        self.type = format
    }
    
    public init(data: Data, dataOptions: CFDictionary, format: AssetType) {
        self.init(data: data, dataOptions: dataOptions)
        self.type = format
    }
    
    public static func encodeImage(_ image: Harbeth.C7Image, options: ImageCoderOptions) -> Data? {
        return nil
    }
}
