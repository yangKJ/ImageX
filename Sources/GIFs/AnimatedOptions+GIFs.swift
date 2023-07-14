//
//  AnimatedOptions+GIFs.swift
//  ImageX
//
//  Created by Condy on 2023/7/12.
//

import Foundation

extension AnimatedOptions {
    
    public struct GIFs {
        
        /// Desired number of loops. Default is ``forever``.
        public var loop: ImageX.Loop = .forever
        
        /// Dynamic image sources become static display of appoint frames.
        /// After this property is not ``.dynamic``, it will become a static image.
        public var frameType: ImageX.DynamicFrameType = .dynamic
        
        /// The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
        public var bufferCount: Int = 50
        
        public init() { }
        
        internal var preparation: ((_ res: ImageX.GIFResponse) -> Void)?
        /// Ready to play time callback.
        /// - Parameter block: Prepare to play the callback.
        public mutating func setPreparationBlock(block: @escaping ((_ res: ImageX.GIFResponse) -> Void)) {
            self.preparation = block
        }
        
        internal var animated: ((_ loopDuration: TimeInterval) -> Void)?
        /// GIF animation playback completed.
        /// - Parameter block: Complete the callback.
        public mutating func setAnimatedBlock(block: @escaping ((_ loopDuration: TimeInterval) -> Void)) {
            self.animated = block
        }
    }
}
