//
//  FrameType.swift
//  ImageX
//
//  Created by Condy on 2023/7/14.
//

import Foundation

/// Dynamic image sources become static display of appoint frames.
public enum DynamicFrameType {
    /// The dynamic map is still displayed.
    case dynamic
    /// Displayed the first frame.
    case frist
    /// Displayed the last frame.
    case last
    /// Displayed appoint the frame, beyond the last frame.
    case appoint(Int)
}

extension DynamicFrameType {
    
    func index(_ frameCount: Int) -> Int {
        switch self {
        case .frist:
            return 0
        case .last:
            return frameCount
        case .appoint(let int):
            return min(frameCount, int)
        default:
            return 0
        }
    }
}
