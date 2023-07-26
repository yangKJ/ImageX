//
//  ImageJPEGCoder.swift
//  ImageX
//
//  Created by Condy on 2023/7/15.
//

import Foundation
import Harbeth

public struct ImageJPEGCoder: ImageCodering {
    
    public var data: Data
    
    public var imageSource: CGImageSource?
    
    public var frameCount: Int = 0
    
    public var format: AssetType {
        .jpeg
    }
    
    public init(data: Data, dataOptions: CFDictionary) {
        self.data = data
        self.setupImageSource(data: data, dataOptions: dataOptions)
    }
    
    public func canDecoderBrokenData() -> Bool {
        return true
    }
    
    public static func encodeImage(_ image: Harbeth.C7Image, options: ImageCoderOptions) -> Data? {
        let compressionQuality = options[ImageCoderOption.encoder.compressionQualityKey] as? CGFloat ?? 1.0
        #if os(macOS)
        guard let cgImage = image.cgImage else {
            return nil
        }
        let rep = NSBitmapImageRep(cgImage: cgImage)
        return rep.representation(using: .jpeg, properties: [.compressionFactor: compressionQuality])
        #else
        return image.jpegData(compressionQuality: compressionQuality)
        #endif
    }
}
