//
//  CVPixelBuffer+Ext.swift
//  Harbeth
//
//  Created by Condy on 2022/2/28.
//

import Foundation
import CoreVideo
import MetalKit
import VideoToolbox

extension CVPixelBuffer: C7Compatible { }

extension Queen where Base: CVPixelBuffer {
    
    private var size: C7Size {
        let width = CVPixelBufferGetWidthOfPlane(self.base, 0)
        let height = CVPixelBufferGetHeightOfPlane(self.base, 0)
        return C7Size(width: width, height: height)
    }
    
    /// Convert cached pixel objects into textures that can be used for camera capture and video frame filters
    /// - Parameters:
    ///   - textureCache: The texture cache object that will manage the texture.
    ///   - pixelFormat: Specifies the Metal pixel format.
    ///   - planeIndex: Specifies the plane of the CVImageBuffer to map bind.  Ignored for non-planar CVImageBuffers.
    /// - Returns: Metal texture.
    public func convert2MTLTexture(textureCache: CVMetalTextureCache?,
                                   pixelFormat: MTLPixelFormat = .bgra8Unorm,
                                   planeIndex: Int = 0) -> MTLTexture? {
        guard let textureCache = textureCache else {
            return nil
        }
        let width  = CVPixelBufferGetWidthOfPlane(self.base, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(self.base, planeIndex)
        #if !targetEnvironment(simulator)
        var cvmTexture: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache,
                                                  self.base,
                                                  nil,
                                                  pixelFormat,
                                                  width,
                                                  height,
                                                  planeIndex,
                                                  &cvmTexture)
        if let cvmTexture = cvmTexture, let texture = CVMetalTextureGetTexture(cvmTexture) {
            return texture
        }
        #endif
        return nil
    }
    
    /// Creates a CGImage using the provided CVPixelBuffer.
    /// - Returns: Newly created CGImage.
    public func toCGImage() -> CGImage? {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(base, options: nil, imageOut: &cgImage)
        return cgImage
    }
    
    /// Copy the texture to the pixel buffer.
    /// - Parameter texture: metal texture.
    public func copyToPixelBuffer(with texture: MTLTexture) {
        let flags = CVPixelBufferLockFlags(rawValue: 0)
        CVPixelBufferLockBaseAddress(base, flags)
        if let pixelBufferBytes = CVPixelBufferGetBaseAddress(base) {
            // Fixed if the CVPixelBuffer and MTLTexture size is not equal.
            // If the size is inconsistent, using the modified size filter will crash.
            // Such as: C7Resize, C7Crop and so on Shape filter.
            if base.mt.size == texture.mt.size {
                let bytesPerRow = CVPixelBufferGetBytesPerRow(base)
                let region = MTLRegionMake2D(0, 0, texture.width, texture.height)
                texture.getBytes(pixelBufferBytes, bytesPerRow: bytesPerRow, from: region, mipmapLevel: 0)
            }
        }
        CVPixelBufferUnlockBaseAddress(base, flags)
    }
    
    /// Creates a CMSampleBuffer that contains a CVImageBuffer instead of a CMBlockBuffer.
    /// - Returns: CMSampleBuffer
    public func toCMSampleBuffer() -> CMSampleBuffer? {
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: base, formatDescriptionOut: &videoInfo)
        guard let videoInfo = videoInfo else {
            return nil
        }
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                           imageBuffer: base,
                                           dataReady: true,
                                           makeDataReadyCallback: nil,
                                           refcon: nil,
                                           formatDescription: videoInfo,
                                           sampleTiming: &timimgInfo,
                                           sampleBufferOut: &newSampleBuffer)
        return newSampleBuffer
    }
        
    /// Convert textures based on different environments and add CVPixelBuffer.
    /// - Parameters:
    ///   - textureCache: The texture cache object that will manage the texture. Only the real machine used.
    /// - Returns: Metal texture.
    public func toMTLTexture(textureCache: CVMetalTextureCache? = nil) -> MTLTexture? {
        let texture: MTLTexture?
        #if targetEnvironment(simulator)
        // The simulator needs to be fixed to `rgba8Unorm`.
        let pixelFormat: MTLPixelFormat = .rgba8Unorm
        texture = base.mt.toCGImage()?.mt.toTexture(pixelFormat: pixelFormat)
        #else
        texture = base.mt.convert2MTLTexture(textureCache: textureCache ?? Device.sharedTextureCache())
        #endif
        return texture
    }
    
    /// Create a new MTLTexture and add CVPixelBuffer.
    /// - Parameters:
    ///   - pixelFormat: Specifies the Metal pixel format.
    ///   - planeIndex: Specifies the plane of the CVImageBuffer to map bind.  Ignored for non-planar CVImageBuffers.
    /// - Returns: New metal texture.
    public func createMTLTexture(pixelFormat: MTLPixelFormat = .bgra8Unorm, planeIndex: Int = 0) -> MTLTexture {
        let width = CVPixelBufferGetWidthOfPlane(self.base, planeIndex)
        let height = CVPixelBufferGetHeightOfPlane(self.base, planeIndex)
        let texture = Processed.destTexture(pixelFormat: pixelFormat, width: width, height: height)
        base.mt.copyToPixelBuffer(with: texture)
        return texture
    }
}
