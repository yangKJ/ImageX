//
//  GIFResponse.swift
//  ImageX
//
//  Created by Condy on 2023/7/3.
//

import Foundation
import Harbeth

public struct GIFResponse {
    
    /// Total duration of one animation loop.
    public let loopDuration: TimeInterval
    
    /// The first frame that is not nil of GIFs.
    public let fristFrame: C7Image?
    
    /// Returns the active frame if available.
    public let activeFrame: C7Image?
    
    /// Total frame count of the GIFs.
    public let frameCount: Int
    
    /// Introspect whether the instance is animating.
    public let isAnimatingGIF: Bool
    
    /// Bitmap memory cost with bytes.
    public let costGIF: Int
    
    /// GIFs data.
    public let data: Data
}
