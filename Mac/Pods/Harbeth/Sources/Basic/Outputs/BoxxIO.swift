//
//  BoxxIO.swift
//  Harbeth
//
//  Created by Condy on 2022/10/22.
//  https://github.com/yangKJ/Harbeth

import Foundation
import MetalKit
import CoreImage
import CoreMedia
import CoreVideo

/// Quickly add filters to sources.
/// Support use ``UIImage/NSImage, CGImage, CIImage, MTLTexture, CMSampleBuffer, CVPixelBuffer``
@frozen public struct BoxxIO<Dest> : Destype {
    public typealias Element = Dest
    public let element: Dest
    public let filters: [C7FilterProtocol]
    
    // Since the camera acquisition generally uses ' kCVPixelFormatType_32BGRA '
    // The pixel format needs to be consistent, otherwise it will appear blue phenomenon.
    public var bufferPixelFormat: MTLPixelFormat = .bgra8Unorm
    
    // When the CIImage is created, it is mirrored and flipped upside down.
    // But upon inspecting the texture, it still renders the CIImage as expected.
    // Nevertheless, we can fix this by simply transforming the CIImage with the downMirrored orientation.
    public var mirrored: Bool = false
    
    #if os(macOS)
    // Fixed an issue with HEIC flipping after adding filter.
    // If drawing a HEIC, we need to make context flipped.
    public var heic: Bool = false
    #endif
    
    public init(element: Dest, filter: C7FilterProtocol) {
        self.init(element: element, filters: [filter])
    }
    
    public init(element: Dest, filters: [C7FilterProtocol]) {
        self.element = element
        self.filters = filters
    }
    
    public func output() throws -> Dest {
        do {
            if let element = element as? C7Image {
                return try filtering(image: element) as! Dest
            }
            if let element = element as? MTLTexture {
                return try filtering(texture: element) as! Dest
            }
            if CFGetTypeID(element as CFTypeRef) == CGImage.typeID {
                return try filtering(cgImage: element as! CGImage) as! Dest
            }
            if let element = element as? CIImage {
                return try filtering(ciImage: element) as! Dest
            }
            if CFGetTypeID(element as CFTypeRef) == CVPixelBufferGetTypeID() {
                return try filtering(pixelBuffer: element as! CVPixelBuffer) as! Dest
            }
            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *),
               CFGetTypeID(element as CFTypeRef) == CMSampleBuffer.typeID {
                return try filtering(sampleBuffer: element as! CMSampleBuffer) as! Dest
            }
        } catch {
            throw error
        }
        return element
    }
}

// MARK: - filtering methods
extension BoxxIO {
    
    func filtering(pixelBuffer: CVPixelBuffer) throws -> CVPixelBuffer {
        if self.filters.isEmpty { return pixelBuffer }
        guard var texture = pixelBuffer.mt.toMTLTexture(textureCache: nil) else {
            throw C7CustomError.source2Texture
        }
        do {
            for filter in filters {
                let OSize = filter.resize(input: C7Size(width: texture.width, height: texture.height))
                // Since the camera acquisition generally uses ' kCVPixelFormatType_32BGRA '
                // The pixel format needs to be consistent, otherwise it will appear blue phenomenon.
                let OTexture = Processed.destTexture(pixelFormat: bufferPixelFormat, width: OSize.width, height: OSize.height)
                texture = try Processed.IO(inTexture: texture, outTexture: OTexture, filter: filter)
            }
            pixelBuffer.mt.copyToPixelBuffer(with: texture)
            return pixelBuffer
        } catch {
            throw error
        }
    }
    
    func filtering(sampleBuffer: CMSampleBuffer) throws -> CMSampleBuffer {
        if self.filters.isEmpty { return sampleBuffer }
        guard var pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            throw C7CustomError.source2Texture
        }
        do {
            pixelBuffer = try filtering(pixelBuffer: pixelBuffer)
            return pixelBuffer.mt.toCMSampleBuffer() ?? sampleBuffer
        } catch {
            throw error
        }
    }
    
    func filtering(ciImage: CIImage) throws -> CIImage {
        if self.filters.isEmpty { return ciImage }
        guard let texture = ciImage.cgImage?.mt.newTexture() else {
            throw C7CustomError.source2Texture
        }
        ciImage.mt.renderImageToTexture(texture, context: Device.context())
        if let ciImg = CIImage(mtlTexture: texture) {
            if mirrored, #available(iOS 11.0, *) {
                // When the CIImage is created, it is mirrored and flipped upside down.
                // But upon inspecting the texture, it still renders the CIImage as expected.
                // Nevertheless, we can fix this by simply transforming the CIImage with the downMirrored orientation.
                return ciImg.oriented(.downMirrored)
            }
            return ciImg
        }
        return ciImage
    }
    
    func filtering(cgImage: CGImage) throws -> CGImage {
        if self.filters.isEmpty { return cgImage }
        guard var texture = cgImage.mt.toTexture() else {
            throw C7CustomError.source2Texture
        }
        do {
            texture = try filtering(texture: texture)
            return texture.mt.toCGImage() ?? cgImage
        } catch {
            throw error
        }
    }
    
    func filtering(image: C7Image) throws -> C7Image {
        if self.filters.isEmpty { return image }
        guard var texture = image.mt.toTexture() else {
            throw C7CustomError.source2Texture
        }
        do {
            texture = try filtering(texture: texture)
            return try fixImageOrientation(texture: texture, base: image)
        } catch {
            throw error
        }
    }
    
    func filtering(texture: MTLTexture) throws -> MTLTexture {
        if self.filters.isEmpty { return texture }
        do {
            var outTexture: MTLTexture = texture
            for filter in filters {
                outTexture = try Processed.IO(inTexture: outTexture, filter: filter)
            }
            return outTexture
        } catch {
            throw error
        }
    }
}

// MARK: - private methods
extension BoxxIO {
    private func fixImageOrientation(texture: MTLTexture, base: C7Image) throws -> C7Image {
        guard let cgImage = texture.mt.toCGImage() else {
            throw C7CustomError.texture2Image
        }
        #if os(iOS) || os(tvOS) || os(watchOS)
        // Fixed an issue with HEIC flipping after adding filter.
        return C7Image(cgImage: cgImage, scale: base.scale, orientation: base.imageOrientation)
        #elseif os(macOS)
        let fImage = cgImage.mt.toC7Image()
        let image = C7Image(size: fImage.size)
        image.lockFocus()
        if self.heic { image.mt.flip(horizontal: true, vertical: true) }
        fImage.draw(in: NSRect(origin: .zero, size: fImage.size))
        image.unlockFocus()
        return image
        #else
        return base
        #endif
    }
}
