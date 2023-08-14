//
//  C7ZoomBlur.swift
//  Harbeth
//
//  Created by Condy on 2022/2/10.
//

import Foundation

/// 缩放模糊效果
public struct C7ZoomBlur: C7FilterProtocol {
    
    /// A multiplier for the blur size, ranging from 0.0 on up, with a default of 0.0
    public var radius: Float = 0
    
    public var blurCenter: C7Point2D = C7Point2D.center
    
    public var modifier: Modifier {
        return .compute(kernel: "C7ZoomBlur")
    }
    
    public var factors: [Float] {
        return [blurCenter.x, blurCenter.y, radius]
    }
    
    public init(radius: Float = 0) {
        self.radius = radius
    }
}
