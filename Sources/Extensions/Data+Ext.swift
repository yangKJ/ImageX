//
//  Data+Ext.swift
//  ImageX
//
//  Created by Condy on 2023/7/12.
//

import Foundation
import Harbeth

extension Queen where Base == Data {
    
    /// Return whether the image source is a dynamic resource.
    public var isAnimated: Bool {
        let options = [String(kCGImageSourceShouldCache): kCFBooleanFalse] as CFDictionary
        let imageSource = CGImageSourceCreateWithData(base as CFData, options) ?? CGImageSourceCreateIncremental(options)
        let count = CGImageSourceGetCount(imageSource)
        return count > 1
    }
    
    /// Determines image size of the image based on the given data.
    /// - Parameter data: Data.
    /// - Returns: Image size.
    public func imageSize() -> CGSize {
        let type = AssetType(data: base)
        var size: CGSize = .zero
        switch type {
        case .jpeg where base.count > 2:
            var size_: CGSize?
            repeat {
                size_ = ImageParser.parse(base, offset: 2, segment: .nextSegment)
            } while size_ == nil
            size = size_ ?? .zero
        case .png where base.count >= 25:
            var size_ = ImageParser.UInt32Size()
            (base as NSData).getBytes(&size_, range: NSRange(location: 16, length: 8))
            size = CGSize(width: Double(CFSwapInt32(size_.width)), height: Double(CFSwapInt32(size_.height)))
        case .gif where base.count >= 11:
            var size_ = ImageParser.UInt16Size()
            (base as NSData).getBytes(&size_, range: NSRange(location: 6, length: 4))
            size = CGSize(width: Double(size_.width), height: Double(size_.height))
        default:
            break
        }
        return size
    }
}
